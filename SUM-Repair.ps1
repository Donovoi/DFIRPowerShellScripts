<#
    .SYNOPSIS
        SUM Repair Script for all files in the SUM folder and run SumECmd.exe
    
    .DESCRIPTION
        Follow steps to repair the SUM so you can run SumECmd.exe again.
        https://svch0st.medium.com/windows-user-access-logs-ual-9580f1100635
    
    .PARAMETER TargetPath
        Specifies the path to KAPE tout folder where the SUM folder is located
    
    .PARAMETER OutputPath
        Specifies the path for the working copy of the SUM and SumECmd.exe Output
    
    .PARAMETER Kape
        Switch parameter, used if the script is being run inside KAPE as a Module. This means this script will utilize the SumECmd binary that resides within .\KAPE\Modules\bin
    
    .PARAMETER SUMECmd
        Please specify where the SumECmd binary resides.
    
    .EXAMPLE
        PS> .\SUM-Repair.ps1 -TargetPath C:\Test\tout
        -OutputPath C:\Test\workingCopySUM
    
    .NOTES
        ===========================================================================
        Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2022 v5.8.201
        Created on:   	3/7/2022 15:06 PM
        Created by:   	Matthew Arbaugh
        ===========================================================================
#>
param
(
	[Parameter(Mandatory = $true,
			   Position = 1,
			   HelpMessage = 'Specifies the path to KAPE tout folder where the SUM folder is located')]
	[String]$TargetPath,
	[Parameter(Mandatory = $true,
			   Position = 2,
			   HelpMessage = 'Specifies the path for the working copy of the SUM folder and SumECmd.exe Output')]
	[String]$OutputPath,
	[Parameter(HelpMessage = 'Switch parameter, used if the script is being run inside KAPE as a Module. This means this script will utilize the SumECmd binary that resides within .\KAPE\Modules\bin')]
	[switch]$Kape,
	[Parameter(HelpMessage = 'Please specify where the SumECmd binary resides.')]
	[String]$SUMECmd = $(
		if ($Kape)
		{
			# If being used as a KAPE module, $PSScriptRoot is .\KAPE\Modules\bin
			(Get-ChildItem -Recurse -Path $PSScriptRoot -Include 'SumECmd.exe').FullName
		}
		else
		{
			# Get path to SumECmd.exe as user input
			Read-Host -Prompt "Enter full path to the executable SumECmd.exe"
		}
	)
)

# If SumECmd.exe is not set, exit
if ([string]::IsNullOrEmpty($SUMECmd))
{
	Write-Host "SUMECmd is not specificed or not found, exiting"
	Exit
}

# Check the path for the SumECmd.exe is valid
else
{
	if (Test-Path  $SUMECmd -PathType Leaf)
	{
		Write-Host "SUMECmd set to," $SUMECmd
	}
	else
	{
		Write-Host $SUMECmd" is NOT a valid path to SumECmd.exe, exiting"
		Exit
	}
}

$workingSUM = $OutputPath

if (Test-Path $workingSUM)
{
	Write-Host (Get-Date).ToString() "| Output folder already Exists"
}
else
{
	New-Item $workingSUM -ItemType Directory | Out-Null
	Write-Host (Get-Date).ToString() "| Output folder Created successfully: $workingSUM "
}

$sourceSUMFolder = Get-ChildItem -Path $TargetPath -filter "SUM" -Directory -Recurse | ForEach-Object { $_.fullname }

# Make a copy of the files within the SUM directory
Write-Host (Get-Date).ToString() "| Copying source files from $TargetPath to $workingSUM"
Copy-Item -Path $sourceSUMFolder\* -Destination $workingSUM

# Undo Read Only attributes to folder and all files therein
Write-Host (Get-Date).ToString() "| Undoing Read Only attributes to all files in $workingSUM"
$Folder = Get-Item -Path $workingSUM
$Folder.Attributes = $Folder.Attributes -band -bnot [System.IO.FileAttributes]::ReadOnly
Get-ChildItem $workingSUM -Recurse | ForEach-Object {
	Write-Host (Get-Date).ToString() "| Undo Read Only attributes for $workingSUM\$_"
	Set-ItemProperty -Path $workingSUM\$_ -Name IsReadOnly -Value $False
}

# Execute this command esentutl.exe /p Current.mdb
Write-Host (Get-Date).ToString() "| Running esentutl.exe -argumentlist /p $workingSUM\Current.mdb -PassThru"
$currentProg = Start-Process -NoNewWindow "esentutl.exe" -argumentlist "/p $workingSUM\Current.mdb" -PassThru
$count = 0
$window = $false
$wshell = New-Object -ComObject wscript.shell;

# Send ok button press to 'Warning' pop up window
while ($count -lt 30 -and $window -eq $false)
{
	$window = $wshell.AppActivate('Warning')
	Start-Sleep 1
	$count++
}
$wshell.SendKeys('~')

# Wait for the esentutl.exe /p Current.mdb command to complete
do { Start-Sleep 1 }
while (Get-Process -Id $currentProg.Id -Ea SilentlyContinue)

# Execute this command esentutl.exe /p SystemIdentity.mdb
Write-Host (Get-Date).ToString() "| Running esentutl.exe -argumentlist /p $workingSUM\SystemIdentity.mdb -PassThru"
$siProg = Start-Process -NoNewWindow "esentutl.exe" -argumentlist "/p $workingSUM\SystemIdentity.mdb" -PassThru
$count = 0
$window = $false
$wshell = New-Object -ComObject wscript.shell;

# Send ok button press to 'Warning' pop up window
while ($count -lt 30 -and $window -eq $false)
{
	$window = $wshell.AppActivate('Warning')
	Start-Sleep 1
	$count++
}
$wshell.SendKeys('~')

# Wait for the esentutl.exe /p SystemIdentity.mdb command to complete
do { Start-Sleep 1 }
while (Get-Process -Id $siProg.Id -Ea SilentlyContinue)

# For each file found
Get-ChildItem | Where-Object { $_.Name -match '^(\{[-A-Z0-9]+?\})\.mdb' } | ForEach-Object{
	# Execute this command esentutl.exe /p "{<GUID>}.mdb"
	Write-Host (Get-Date).ToString() "| Running esentutl.exe -argumentlist /p $workingSUM\$_ -PassThru"
	$Prog = Start-Process -NoNewWindow "esentutl.exe" -argumentlist "/p $workingSUM\$_" -PassThru
	$count = 0
	$window = $false
	$wshell = New-Object -ComObject wscript.shell;
	
	# Send ok button press to 'Warning' pop up window
	while ($count -lt 30 -and $window -eq $false)
	{
		$window = $wshell.AppActivate('Warning')
		Start-Sleep 1
		$count++
	}
	$wshell.SendKeys('~')
	
	# Wait for the esentutl.exe /p {<GUID>}.mdb command to complete
	do { Start-Sleep 1 }
	while (Get-Process -Id $Prog.Id -Ea SilentlyContinue)
}

# Try running SumECmd again against the location where these repaired files reside
Write-Host (Get-Date).ToString() "| $SUMECmd -argumentlist -d $workingSUM --csv $workingSUM --debug"
Start-Process -NoNewWindow $SUMECmd -argumentlist "-d $workingSUM --csv $workingSUM --debug"

# SIG # Begin signature block
# MIIpGQYJKoZIhvcNAQcCoIIpCjCCKQYCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDp/vv2nPc+Y7Er
# HibJLjw/OE1+oGwdxJR2iNTakwrOB6CCEgowggVvMIIEV6ADAgECAhBI/JO0YFWU
# jTanyYqJ1pQWMA0GCSqGSIb3DQEBDAUAMHsxCzAJBgNVBAYTAkdCMRswGQYDVQQI
# DBJHcmVhdGVyIE1hbmNoZXN0ZXIxEDAOBgNVBAcMB1NhbGZvcmQxGjAYBgNVBAoM
# EUNvbW9kbyBDQSBMaW1pdGVkMSEwHwYDVQQDDBhBQUEgQ2VydGlmaWNhdGUgU2Vy
# dmljZXMwHhcNMjEwNTI1MDAwMDAwWhcNMjgxMjMxMjM1OTU5WjBWMQswCQYDVQQG
# EwJHQjEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMS0wKwYDVQQDEyRTZWN0aWdv
# IFB1YmxpYyBDb2RlIFNpZ25pbmcgUm9vdCBSNDYwggIiMA0GCSqGSIb3DQEBAQUA
# A4ICDwAwggIKAoICAQCN55QSIgQkdC7/FiMCkoq2rjaFrEfUI5ErPtx94jGgUW+s
# hJHjUoq14pbe0IdjJImK/+8Skzt9u7aKvb0Ffyeba2XTpQxpsbxJOZrxbW6q5KCD
# J9qaDStQ6Utbs7hkNqR+Sj2pcaths3OzPAsM79szV+W+NDfjlxtd/R8SPYIDdub7
# P2bSlDFp+m2zNKzBenjcklDyZMeqLQSrw2rq4C+np9xu1+j/2iGrQL+57g2extme
# me/G3h+pDHazJyCh1rr9gOcB0u/rgimVcI3/uxXP/tEPNqIuTzKQdEZrRzUTdwUz
# T2MuuC3hv2WnBGsY2HH6zAjybYmZELGt2z4s5KoYsMYHAXVn3m3pY2MeNn9pib6q
# RT5uWl+PoVvLnTCGMOgDs0DGDQ84zWeoU4j6uDBl+m/H5x2xg3RpPqzEaDux5mcz
# mrYI4IAFSEDu9oJkRqj1c7AGlfJsZZ+/VVscnFcax3hGfHCqlBuCF6yH6bbJDoEc
# QNYWFyn8XJwYK+pF9e+91WdPKF4F7pBMeufG9ND8+s0+MkYTIDaKBOq3qgdGnA2T
# OglmmVhcKaO5DKYwODzQRjY1fJy67sPV+Qp2+n4FG0DKkjXp1XrRtX8ArqmQqsV/
# AZwQsRb8zG4Y3G9i/qZQp7h7uJ0VP/4gDHXIIloTlRmQAOka1cKG8eOO7F/05QID
# AQABo4IBEjCCAQ4wHwYDVR0jBBgwFoAUoBEKIz6W8Qfs4q8p74Klf9AwpLQwHQYD
# VR0OBBYEFDLrkpr/NZZILyhAQnAgNpFcF4XmMA4GA1UdDwEB/wQEAwIBhjAPBgNV
# HRMBAf8EBTADAQH/MBMGA1UdJQQMMAoGCCsGAQUFBwMDMBsGA1UdIAQUMBIwBgYE
# VR0gADAIBgZngQwBBAEwQwYDVR0fBDwwOjA4oDagNIYyaHR0cDovL2NybC5jb21v
# ZG9jYS5jb20vQUFBQ2VydGlmaWNhdGVTZXJ2aWNlcy5jcmwwNAYIKwYBBQUHAQEE
# KDAmMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5jb21vZG9jYS5jb20wDQYJKoZI
# hvcNAQEMBQADggEBABK/oe+LdJqYRLhpRrWrJAoMpIpnuDqBv0WKfVIHqI0fTiGF
# OaNrXi0ghr8QuK55O1PNtPvYRL4G2VxjZ9RAFodEhnIq1jIV9RKDwvnhXRFAZ/ZC
# J3LFI+ICOBpMIOLbAffNRk8monxmwFE2tokCVMf8WPtsAO7+mKYulaEMUykfb9gZ
# pk+e96wJ6l2CxouvgKe9gUhShDHaMuwV5KZMPWw5c9QLhTkg4IUaaOGnSDip0TYl
# d8GNGRbFiExmfS9jzpjoad+sPKhdnckcW67Y8y90z7h+9teDnRGWYpquRRPaf9xH
# +9/DUp/mBlXpnYzyOmJRvOwkDynUWICE5EV7WtgwggYaMIIEAqADAgECAhBiHW0M
# UgGeO5B5FSCJIRwKMA0GCSqGSIb3DQEBDAUAMFYxCzAJBgNVBAYTAkdCMRgwFgYD
# VQQKEw9TZWN0aWdvIExpbWl0ZWQxLTArBgNVBAMTJFNlY3RpZ28gUHVibGljIENv
# ZGUgU2lnbmluZyBSb290IFI0NjAeFw0yMTAzMjIwMDAwMDBaFw0zNjAzMjEyMzU5
# NTlaMFQxCzAJBgNVBAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxKzAp
# BgNVBAMTIlNlY3RpZ28gUHVibGljIENvZGUgU2lnbmluZyBDQSBSMzYwggGiMA0G
# CSqGSIb3DQEBAQUAA4IBjwAwggGKAoIBgQCbK51T+jU/jmAGQ2rAz/V/9shTUxjI
# ztNsfvxYB5UXeWUzCxEeAEZGbEN4QMgCsJLZUKhWThj/yPqy0iSZhXkZ6Pg2A2NV
# DgFigOMYzB2OKhdqfWGVoYW3haT29PSTahYkwmMv0b/83nbeECbiMXhSOtbam+/3
# 6F09fy1tsB8je/RV0mIk8XL/tfCK6cPuYHE215wzrK0h1SWHTxPbPuYkRdkP05Zw
# mRmTnAO5/arnY83jeNzhP06ShdnRqtZlV59+8yv+KIhE5ILMqgOZYAENHNX9SJDm
# +qxp4VqpB3MV/h53yl41aHU5pledi9lCBbH9JeIkNFICiVHNkRmq4TpxtwfvjsUe
# dyz8rNyfQJy/aOs5b4s+ac7IH60B+Ja7TVM+EKv1WuTGwcLmoU3FpOFMbmPj8pz4
# 4MPZ1f9+YEQIQty/NQd/2yGgW+ufflcZ/ZE9o1M7a5Jnqf2i2/uMSWymR8r2oQBM
# dlyh2n5HirY4jKnFH/9gRvd+QOfdRrJZb1sCAwEAAaOCAWQwggFgMB8GA1UdIwQY
# MBaAFDLrkpr/NZZILyhAQnAgNpFcF4XmMB0GA1UdDgQWBBQPKssghyi47G9IritU
# pimqF6TNDDAOBgNVHQ8BAf8EBAMCAYYwEgYDVR0TAQH/BAgwBgEB/wIBADATBgNV
# HSUEDDAKBggrBgEFBQcDAzAbBgNVHSAEFDASMAYGBFUdIAAwCAYGZ4EMAQQBMEsG
# A1UdHwREMEIwQKA+oDyGOmh0dHA6Ly9jcmwuc2VjdGlnby5jb20vU2VjdGlnb1B1
# YmxpY0NvZGVTaWduaW5nUm9vdFI0Ni5jcmwwewYIKwYBBQUHAQEEbzBtMEYGCCsG
# AQUFBzAChjpodHRwOi8vY3J0LnNlY3RpZ28uY29tL1NlY3RpZ29QdWJsaWNDb2Rl
# U2lnbmluZ1Jvb3RSNDYucDdjMCMGCCsGAQUFBzABhhdodHRwOi8vb2NzcC5zZWN0
# aWdvLmNvbTANBgkqhkiG9w0BAQwFAAOCAgEABv+C4XdjNm57oRUgmxP/BP6YdURh
# w1aVcdGRP4Wh60BAscjW4HL9hcpkOTz5jUug2oeunbYAowbFC2AKK+cMcXIBD0Zd
# OaWTsyNyBBsMLHqafvIhrCymlaS98+QpoBCyKppP0OcxYEdU0hpsaqBBIZOtBajj
# cw5+w/KeFvPYfLF/ldYpmlG+vd0xqlqd099iChnyIMvY5HexjO2AmtsbpVn0OhNc
# WbWDRF/3sBp6fWXhz7DcML4iTAWS+MVXeNLj1lJziVKEoroGs9Mlizg0bUMbOalO
# hOfCipnx8CaLZeVme5yELg09Jlo8BMe80jO37PU8ejfkP9/uPak7VLwELKxAMcJs
# zkyeiaerlphwoKx1uHRzNyE6bxuSKcutisqmKL5OTunAvtONEoteSiabkPVSZ2z7
# 6mKnzAfZxCl/3dq3dUNw4rg3sTCggkHSRqTqlLMS7gjrhTqBmzu1L90Y1KWN/Y5J
# KdGvspbOrTfOXyXvmPL6E52z1NZJ6ctuMFBQZH3pwWvqURR8AgQdULUvrxjUYbHH
# j95Ejza63zdrEcxWLDX6xWls/GDnVNueKjWUH3fTv1Y8Wdho698YADR7TNx8X8z2
# Bev6SivBBOHY+uqiirZtg0y9ShQoPzmCcn63Syatatvx157YK9hlcPmVoa1oDE5/
# L9Uo2bC5a4CH2RwwggZ1MIIE3aADAgECAhA1nosluv9RC3xO0e22wmkkMA0GCSqG
# SIb3DQEBDAUAMFQxCzAJBgNVBAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0
# ZWQxKzApBgNVBAMTIlNlY3RpZ28gUHVibGljIENvZGUgU2lnbmluZyBDQSBSMzYw
# HhcNMjIwMTI3MDAwMDAwWhcNMjUwMTI2MjM1OTU5WjBSMQswCQYDVQQGEwJVUzER
# MA8GA1UECAwITWljaGlnYW4xFzAVBgNVBAoMDkFuZHJldyBSYXRoYnVuMRcwFQYD
# VQQDDA5BbmRyZXcgUmF0aGJ1bjCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoC
# ggIBALe0CgT89ev6jRIhHdrp9cdPnRoF5AV3wQdWzNG8JiY4dpN1YVwGLlw8aBos
# m0NIRz2/y/kriL+Jdu/FFakJdpB8l/J+mesliYhN+zj9vFviBjrElMASEBS9DXKa
# UFuqZMGiC6k6yASGfyqF121OkLZ2JImy4a0C43Pd74dbf+/Ae4QHj66otahUBL++
# 7ayba/TJebhRdEq0wFiaxYsZOt18c3LLfAw0fniHfMBZXXJAQhgu1xfgpw7OE4N/
# M5or5VDVQ4ovtSFDVRzRARIF4ibZZqB76Rp5MuI0pMCs74TPN6WdlzGTDBu4pTS0
# 64iGx5hlP+GB5s/w/YW1BDigFV6yaERsbet9G2lsMmNwZtI6zUuGd9HEtd5isz/9
# ENhLcFoaJE7/KK8CL5jt8i9I3Lx+5EOgEwm65eHm45bq63AVKvSHrjisuxX89jWT
# eslKMM/rpw8GMrNBxo9DZvDS4+kCloFKARiwKHJIKpNWUT3T8Kw6Q/ayxUt7TKp+
# cqh0U9YoXLbXIYMpLa5KfOsf21SqfSrhJ+rSEPEBM11uX41T/mQD5sArN9AIPQxp
# 6X7qLckzClylAQgzF2OVHEEi5m2kmb0lvfMOMGQ3BgwQHCRcd65wugzCIipb5KBT
# q+HJLgRWFwYGraxcfsLkkwBY1ssKPaVpAgMDmlWJo6hDoYR9AgMBAAGjggHDMIIB
# vzAfBgNVHSMEGDAWgBQPKssghyi47G9IritUpimqF6TNDDAdBgNVHQ4EFgQUUwhn
# 1KEy//RT4cMg1UJfMUX5lBcwDgYDVR0PAQH/BAQDAgeAMAwGA1UdEwEB/wQCMAAw
# EwYDVR0lBAwwCgYIKwYBBQUHAwMwEQYJYIZIAYb4QgEBBAQDAgQQMEoGA1UdIARD
# MEEwNQYMKwYBBAGyMQECAQMCMCUwIwYIKwYBBQUHAgEWF2h0dHBzOi8vc2VjdGln
# by5jb20vQ1BTMAgGBmeBDAEEATBJBgNVHR8EQjBAMD6gPKA6hjhodHRwOi8vY3Js
# LnNlY3RpZ28uY29tL1NlY3RpZ29QdWJsaWNDb2RlU2lnbmluZ0NBUjM2LmNybDB5
# BggrBgEFBQcBAQRtMGswRAYIKwYBBQUHMAKGOGh0dHA6Ly9jcnQuc2VjdGlnby5j
# b20vU2VjdGlnb1B1YmxpY0NvZGVTaWduaW5nQ0FSMzYuY3J0MCMGCCsGAQUFBzAB
# hhdodHRwOi8vb2NzcC5zZWN0aWdvLmNvbTAlBgNVHREEHjAcgRphbmRyZXcuZC5y
# YXRoYnVuQGdtYWlsLmNvbTANBgkqhkiG9w0BAQwFAAOCAYEATPy2wx+JfB71i+UC
# YCOjFFBqrA4kCxsHv3ihLjF4N3g8jb7A156vBangR3BDPQ6lF0YCPwEFE9MQzqG7
# OgkUauX0vfPeuVe8cEadUFlrmb6xCmXsxKdGXObaITeGABz97AzLKxgxRf7xCEKs
# AzvbuaK3lvb3Me9jtRVn9Q69sBTE5I/IDf2PoG/tO/ibPYXC1KpilBNT0A28xMtQ
# 1ijTS0dnbOyTMaUBCZUrNR/9qY2sOBhvxuvSouWjuEazDLTCs6zsMBQH9vfrLoNl
# vEXI5YO9Ck19kT9pZ2rGFO7y8ySRmoVpZvHI29Z4bXBtGUGb2g/RRppid5anuRtN
# +Skr7S1wdrNlhBIYErmCUPH2RPMphN2wmUy6IsDpdTPJkPTmU83q3tpOBGwvyTdx
# hiPIurZMXSDXfUyGB2iiXoyUHP2caVUmsarEb3BgCEf0PT2rO971WCDnG0mMgle2
# Yur4z3eWEsKUoPdFAoiizb7CddijTOsNvxYNf0XEg5Ek1gTSMYIWZTCCFmECAQEw
# aDBUMQswCQYDVQQGEwJHQjEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSswKQYD
# VQQDEyJTZWN0aWdvIFB1YmxpYyBDb2RlIFNpZ25pbmcgQ0EgUjM2AhA1nosluv9R
# C3xO0e22wmkkMA0GCWCGSAFlAwQCAQUAoHwwEAYKKwYBBAGCNwIBDDECMAAwGQYJ
# KoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQB
# gjcCARUwLwYJKoZIhvcNAQkEMSIEIDzPRZ4Qbe0cIQ6WbtEizbPkhobfl/R3IvYQ
# 4TLp1jHsMA0GCSqGSIb3DQEBAQUABIICAKvH+9/7mHGpa39ymLkkllpGsMgi0dvA
# 25qNBe3BZSSzBNClcXH1R6VyX/gHzKVB4G1rz8FY9S8VMqvWvEF6kSImfTlH1I9N
# dSxyvTVjcginRvHSU0wLO0DIHtQaa1JIi6XTQsZXMhwyaAXZ0ilfb3paiAwPKM+d
# tGfhL+unFI8LVGFndt7DKbFrHPC2CYMGOsBz3rDAmwuW9emVxer9Jt5qVhZll7CS
# sRb6ji6LcZsdILB8UZjKA0jPpdHxa9hEp/axXATCSvqAugrn4GtcGWkhO59Nv+RM
# LGFkBek3IyeYqST+UCxE5OpCF10sdezAMPbFAqCzUqkI+T4QhFBmbtvNu8vJkTvR
# pRuLtlNQdbstu6o3MTisXOMQbbK90JnV172URm3MWazwnd2bqlvY2MDHs/e/wiUo
# a25mgSeluWFD6J4rZ5KbVaX0H3asHq4tm0IoJQjr7V9gY0KTSGH1m23c0X6EkhLB
# 4j5jXEucChrhLzR6B/5x1SA27wavR5CdYCS1vldm6nuHe0rjHzG42cjRvutjC3Ks
# TRXJIBr+CMzIuC06iBQmRhgCGRO5LFellXbcM5temt2hqzFUNoydt8O1KGTzhYtc
# HcfoK9hJifwa2qJJd1nfKi3hfHguzdO3h1rpLSbsZRyKyltokaROt7esdsRiKLco
# KgmPjdq+KjyZoYITUDCCE0wGCisGAQQBgjcDAwExghM8MIITOAYJKoZIhvcNAQcC
# oIITKTCCEyUCAQMxDzANBglghkgBZQMEAgIFADCB7wYLKoZIhvcNAQkQAQSggd8E
# gdwwgdkCAQEGCisGAQQBsjECAQEwMTANBglghkgBZQMEAgEFAAQgcw0JwO4w/nmd
# KWQFY1uR0FLpD76GvJwyQSkMYuE/tIICFHuTVms7l4MoURhIMiF/tylURYhGGA8y
# MDIzMDQwODAyMTcyNVqgbqRsMGoxCzAJBgNVBAYTAkdCMRMwEQYDVQQIEwpNYW5j
# aGVzdGVyMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxLDAqBgNVBAMMI1NlY3Rp
# Z28gUlNBIFRpbWUgU3RhbXBpbmcgU2lnbmVyICMzoIIN6jCCBvYwggTeoAMCAQIC
# EQCQOX+a0ko6E/K9kV8IOKlDMA0GCSqGSIb3DQEBDAUAMH0xCzAJBgNVBAYTAkdC
# MRswGQYDVQQIExJHcmVhdGVyIE1hbmNoZXN0ZXIxEDAOBgNVBAcTB1NhbGZvcmQx
# GDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDElMCMGA1UEAxMcU2VjdGlnbyBSU0Eg
# VGltZSBTdGFtcGluZyBDQTAeFw0yMjA1MTEwMDAwMDBaFw0zMzA4MTAyMzU5NTla
# MGoxCzAJBgNVBAYTAkdCMRMwEQYDVQQIEwpNYW5jaGVzdGVyMRgwFgYDVQQKEw9T
# ZWN0aWdvIExpbWl0ZWQxLDAqBgNVBAMMI1NlY3RpZ28gUlNBIFRpbWUgU3RhbXBp
# bmcgU2lnbmVyICMzMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAkLJx
# P3nh1LmKF8zDl8KQlHLtWjpvAUN/c1oonyR8oDVABvqUrwqhg7YT5EsVBl5qiiA0
# cXu7Ja0/WwqkHy9sfS5hUdCMWTc+pl3xHl2AttgfYOPNEmqIH8b+GMuTQ1Z6x84D
# 1gBkKFYisUsZ0vCWyUQfOV2csJbtWkmNfnLkQ2t/yaA/bEqt1QBPvQq4g8W9mCwH
# dgFwRd7D8EJp6v8mzANEHxYo4Wp0tpxF+rY6zpTRH72MZar9/MM86A2cOGbV/H0e
# m1mMkVpCV1VQFg1LdHLuoCox/CYCNPlkG1n94zrU6LhBKXQBPw3gE3crETz7Pc3Q
# 5+GXW1X3KgNt1c1i2s6cHvzqcH3mfUtozlopYdOgXCWzpSdoo1j99S1ryl9kx2so
# DNqseEHeku8Pxeyr3y1vGlRRbDOzjVlg59/oFyKjeUFiz/x785LaruA8Tw9azG7f
# H7wir7c4EJo0pwv//h1epPPuFjgrP6x2lEGdZB36gP0A4f74OtTDXrtpTXKZ5fEy
# LVH6Ya1N6iaObfypSJg+8kYNabG3bvQF20EFxhjAUOT4rf6sY2FHkbxGtUZTbMX0
# 4YYnk4Q5bHXgHQx6WYsuy/RkLEJH9FRYhTflx2mn0iWLlr/GreC9sTf3H99Ce6rr
# HOnrPVrd+NKQ1UmaOh2DGld/HAHCzhx9zPuWFcUCAwEAAaOCAYIwggF+MB8GA1Ud
# IwQYMBaAFBqh+GEZIA/DQXdFKI7RNV8GEgRVMB0GA1UdDgQWBBQlLmg8a5orJBSp
# H6LfJjrPFKbx4DAOBgNVHQ8BAf8EBAMCBsAwDAYDVR0TAQH/BAIwADAWBgNVHSUB
# Af8EDDAKBggrBgEFBQcDCDBKBgNVHSAEQzBBMDUGDCsGAQQBsjEBAgEDCDAlMCMG
# CCsGAQUFBwIBFhdodHRwczovL3NlY3RpZ28uY29tL0NQUzAIBgZngQwBBAIwRAYD
# VR0fBD0wOzA5oDegNYYzaHR0cDovL2NybC5zZWN0aWdvLmNvbS9TZWN0aWdvUlNB
# VGltZVN0YW1waW5nQ0EuY3JsMHQGCCsGAQUFBwEBBGgwZjA/BggrBgEFBQcwAoYz
# aHR0cDovL2NydC5zZWN0aWdvLmNvbS9TZWN0aWdvUlNBVGltZVN0YW1waW5nQ0Eu
# Y3J0MCMGCCsGAQUFBzABhhdodHRwOi8vb2NzcC5zZWN0aWdvLmNvbTANBgkqhkiG
# 9w0BAQwFAAOCAgEAc9rtaHLLwrlAoTG7tAOjLRR7JOe0WxV9qOn9rdGSDXw9NqBp
# 2fOaMNqsadZ0VyQ/fg882fXDeSVsJuiNaJPO8XeJOX+oBAXaNMMU6p8IVKv/xH6W
# bCvTlOu0bOBFTSyy9zs7WrXB+9eJdW2YcnL29wco89Oy0OsZvhUseO/NRaAA5PgE
# drtXxZC+d1SQdJ4LT03EqhOPl68BNSvLmxF46fL5iQQ8TuOCEmLrtEQMdUHCDzS4
# iJ3IIvETatsYL254rcQFtOiECJMH+X2D/miYNOR35bHOjJRs2wNtKAVHfpsu8GT7
# 26QDMRB8Gvs8GYDRC3C5VV9HvjlkzrfaI1Qy40ayMtjSKYbJFV2Ala8C+7TRLp04
# fDXgDxztG0dInCJqVYLZ8roIZQPl8SnzSIoJAUymefKithqZlOuXKOG+fRuhfO1W
# gKb0IjOQ5IRT/Cr6wKeXqOq1jXrO5OBLoTOrC3ag1WkWt45mv1/6H8Sof6ehSBSR
# DYL8vU2Z7cnmbDb+d0OZuGktfGEv7aOwSf5bvmkkkf+T/FdpkkvZBT9thnLTotDA
# ZNI6QsEaA/vQ7ZohuD+vprJRVNVMxcofEo1XxjntXP/snyZ2rWRmZ+iqMODSrbd9
# sWpBJ24DiqN04IoJgm6/4/a3vJ4LKRhogaGcP24WWUsUCQma5q6/YBXdhvUwggbs
# MIIE1KADAgECAhAwD2+s3WaYdHypRjaneC25MA0GCSqGSIb3DQEBDAUAMIGIMQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKTmV3IEplcnNleTEUMBIGA1UEBxMLSmVyc2V5
# IENpdHkxHjAcBgNVBAoTFVRoZSBVU0VSVFJVU1QgTmV0d29yazEuMCwGA1UEAxMl
# VVNFUlRydXN0IFJTQSBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eTAeFw0xOTA1MDIw
# MDAwMDBaFw0zODAxMTgyMzU5NTlaMH0xCzAJBgNVBAYTAkdCMRswGQYDVQQIExJH
# cmVhdGVyIE1hbmNoZXN0ZXIxEDAOBgNVBAcTB1NhbGZvcmQxGDAWBgNVBAoTD1Nl
# Y3RpZ28gTGltaXRlZDElMCMGA1UEAxMcU2VjdGlnbyBSU0EgVGltZSBTdGFtcGlu
# ZyBDQTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAMgbAa/ZLH6ImX0B
# mD8gkL2cgCFUk7nPoD5T77NawHbWGgSlzkeDtevEzEk0y/NFZbn5p2QWJgn71TJS
# eS7JY8ITm7aGPwEFkmZvIavVcRB5h/RGKs3EWsnb111JTXJWD9zJ41OYOioe/M5Y
# SdO/8zm7uaQjQqzQFcN/nqJc1zjxFrJw06PE37PFcqwuCnf8DZRSt/wflXMkPQEo
# vA8NT7ORAY5unSd1VdEXOzQhe5cBlK9/gM/REQpXhMl/VuC9RpyCvpSdv7QgsGB+
# uE31DT/b0OqFjIpWcdEtlEzIjDzTFKKcvSb/01Mgx2Bpm1gKVPQF5/0xrPnIhRfH
# uCkZpCkvRuPd25Ffnz82Pg4wZytGtzWvlr7aTGDMqLufDRTUGMQwmHSCIc9iVrUh
# cxIe/arKCFiHd6QV6xlV/9A5VC0m7kUaOm/N14Tw1/AoxU9kgwLU++Le8bwCKPRt
# 2ieKBtKWh97oaw7wW33pdmmTIBxKlyx3GSuTlZicl57rjsF4VsZEJd8GEpoGLZ8D
# Xv2DolNnyrH6jaFkyYiSWcuoRsDJ8qb/fVfbEnb6ikEk1Bv8cqUUotStQxykSYtB
# ORQDHin6G6UirqXDTYLQjdprt9v3GEBXc/Bxo/tKfUU2wfeNgvq5yQ1TgH36tjlY
# Mu9vGFCJ10+dM70atZ2h3pVBeqeDAgMBAAGjggFaMIIBVjAfBgNVHSMEGDAWgBRT
# eb9aqitKz1SA4dibwJ3ysgNmyzAdBgNVHQ4EFgQUGqH4YRkgD8NBd0UojtE1XwYS
# BFUwDgYDVR0PAQH/BAQDAgGGMBIGA1UdEwEB/wQIMAYBAf8CAQAwEwYDVR0lBAww
# CgYIKwYBBQUHAwgwEQYDVR0gBAowCDAGBgRVHSAAMFAGA1UdHwRJMEcwRaBDoEGG
# P2h0dHA6Ly9jcmwudXNlcnRydXN0LmNvbS9VU0VSVHJ1c3RSU0FDZXJ0aWZpY2F0
# aW9uQXV0aG9yaXR5LmNybDB2BggrBgEFBQcBAQRqMGgwPwYIKwYBBQUHMAKGM2h0
# dHA6Ly9jcnQudXNlcnRydXN0LmNvbS9VU0VSVHJ1c3RSU0FBZGRUcnVzdENBLmNy
# dDAlBggrBgEFBQcwAYYZaHR0cDovL29jc3AudXNlcnRydXN0LmNvbTANBgkqhkiG
# 9w0BAQwFAAOCAgEAbVSBpTNdFuG1U4GRdd8DejILLSWEEbKw2yp9KgX1vDsn9Fqg
# uUlZkClsYcu1UNviffmfAO9Aw63T4uRW+VhBz/FC5RB9/7B0H4/GXAn5M17qoBwm
# WFzztBEP1dXD4rzVWHi/SHbhRGdtj7BDEA+N5Pk4Yr8TAcWFo0zFzLJTMJWk1vSW
# Vgi4zVx/AZa+clJqO0I3fBZ4OZOTlJux3LJtQW1nzclvkD1/RXLBGyPWwlWEZuSz
# xWYG9vPWS16toytCiiGS/qhvWiVwYoFzY16gu9jc10rTPa+DBjgSHSSHLeT8AtY+
# dwS8BDa153fLnC6NIxi5o8JHHfBd1qFzVwVomqfJN2Udvuq82EKDQwWli6YJ/9Gh
# lKZOqj0J9QVst9JkWtgqIsJLnfE5XkzeSD2bNJaaCV+O/fexUpHOP4n2HKG1qXUf
# cb9bQ11lPVCBbqvw0NP8srMftpmWJvQ8eYtcZMzN7iea5aDADHKHwW5NWtMe6vBE
# 5jJvHOsXTpTDeGUgOw9Bqh/poUGd/rG4oGUqNODeqPk85sEwu8CgYyz8XBYAqNDE
# f+oRnR4GxqZtMl20OAkrSQeq/eww2vGnL8+3/frQo4TZJ577AWZ3uVYQ4SBuxq6x
# +ba6yDVdM3aO8XwgDCp3rrWiAoa6Ke60WgCxjKvj+QrJVF3UuWp0nr1IrpgxggQt
# MIIEKQIBATCBkjB9MQswCQYDVQQGEwJHQjEbMBkGA1UECBMSR3JlYXRlciBNYW5j
# aGVzdGVyMRAwDgYDVQQHEwdTYWxmb3JkMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0
# ZWQxJTAjBgNVBAMTHFNlY3RpZ28gUlNBIFRpbWUgU3RhbXBpbmcgQ0ECEQCQOX+a
# 0ko6E/K9kV8IOKlDMA0GCWCGSAFlAwQCAgUAoIIBazAaBgkqhkiG9w0BCQMxDQYL
# KoZIhvcNAQkQAQQwHAYJKoZIhvcNAQkFMQ8XDTIzMDQwODAyMTcyNVowPwYJKoZI
# hvcNAQkEMTIEMCcgU18U5xSMpqDMT9WAj32Ej//xTjgrz1DiDzRbjnNM62KrvJP3
# wGn7khteWuClHDCB7QYLKoZIhvcNAQkQAgwxgd0wgdowgdcwFgQUqzQBOqxAlzGf
# CBrwsxjhg/gPeIEwgbwEFALWW5Xig3DBVwCV+oj5I92Tf62PMIGjMIGOpIGLMIGI
# MQswCQYDVQQGEwJVUzETMBEGA1UECBMKTmV3IEplcnNleTEUMBIGA1UEBxMLSmVy
# c2V5IENpdHkxHjAcBgNVBAoTFVRoZSBVU0VSVFJVU1QgTmV0d29yazEuMCwGA1UE
# AxMlVVNFUlRydXN0IFJTQSBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eQIQMA9vrN1m
# mHR8qUY2p3gtuTANBgkqhkiG9w0BAQEFAASCAgBUoL3Pw8p4qynIKMM2cxJpK0Xu
# W1ADO6p35h80+GEmjbml79U3MTDNofEAJrRxZ/TSX+SRSmkGh9VZ3q2n3W2Buxa1
# kjQYtu42Nu4taSpt/NcrItdSNBXiGG8Bi/2VUsrbkWEohBdbse5eLdddb4rxDtnk
# rsIAJ8Okw+VdmDG7YzMovD60p2V9T16xTYW4lBdTF2iIh65Lt3kYR6IQ1lEKcRSv
# j4oSiV9L6yYFgfJnRJTU5+FvW8pVF548SXojMD+deKDff7enKX8PV3o65u6EFCos
# ChQnq9TSae98Kf7g8cyBlBPQolkyEhCSBSebd4pVSNUoZyV8dHObrNJYXohQcXS6
# 2sVadB83l+6QnmlVYY4wbfKT5b3X3z2eOUhJqtfLPw4ufVAPVrDupOj1v2LXEj3u
# HBdSYRAL3JywiZWqNMJN4CUG+S1wefsZVbgxYZRJ6M0vpD8TBuxvxFNWv5JqdvmY
# IFV1ZMI1zpHwpVqYaxGBcYP+TRqcav0roGgTGzuDzOyKw7I3qTf+kvHrBgO9ZohM
# lPzP3SqJ8KnocsQ0RnAx+QM56Ai3MzKDQ5svbwQofEMlN+hXgMdWCTEHPfoUwe/r
# YWs8eijgrsrWxbcdhBi2Fkk4QubBpIL/ejg6dyNabQFaLJkThp5M1QjDoSrYtB/Y
# TYlfvX0QCTiFCX6hAw==
# SIG # End signature block
