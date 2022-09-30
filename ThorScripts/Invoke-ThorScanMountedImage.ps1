﻿<#
    .SYNOPSIS
        Easily use Thor against a mounted image!
    
    .DESCRIPTION
        Please note, this script will required a fully licensed version of Thor. Specifically, the Lab license is required for this script to work.
    
    .PARAMETER DriveLetter
        Please provide the drive letter for the image you've mounted!
    
    .PARAMETER OutputPath
        Please provide where you want the Thor report to output to. Thor will create the folder path even if it doesn't already exist prior to this command being ran.
    
    .PARAMETER MaxFileSizeInMB
        Please provide the max file size (in megabytes) of files you want Thor to scan. Thor requires the value in bytes, but this script will do the work for you so you only have to provide the value in megabytes. For example, 1000000000 (9 zeroes) means Thor will scan files 1000MB or less only. Change the 1 to any other number to work in values of thousands of megabytes. The default is 2000MB.
    
    .NOTES
        ===========================================================================
        Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2022 v5.8.210
        Created on:   	2022-09-28 10:20
        Created by:   	Andrew Rathbun
        Organization: 	Kroll
        Filename:       Invoke-ThorScanMountedImage.ps1
        ===========================================================================
#>
param
(
    [Parameter(Mandatory = $true,
               Position = 1,
               HelpMessage = 'Please provide the path to the image mounted as a drive letter. Use Arsenal Image Mounter! Mount as temporary read/write with the differencing file')]
    [String]$DriveLetter,
    [Parameter(Mandatory = $true,
               Position = 2,
               HelpMessage = 'Please provide where you want the Thor report to output to')]
    [String]$OutputPath,
    [Parameter(Mandatory = $true,
               Position = 3,
               HelpMessage = 'Please provide the max file size (in megabytes) of files you want Thor to scan. For example, 1000 (3 zeroes) means Thor will scan files 1000MB or less only. Change the 1 to any other number to work in values of thousands of megabytes.')]
    [String]$MaxFileSizeInMB
)

$DriveLetterVirtualMapping = $DriveLetter + ":C"
$MaxFileSizeConverted = $MaxFileSizeInMB + "000000"

$Thor = Get-ChildItem -Recurse -Path $PSScriptRoot -Include 'thor64.exe'

Start-Process -FilePath $Thor -ArgumentList "--lab -p $DriveLetter --virtual-map $DriveLetterVirtualMapping -e $OutputPath\Thor --max_file_size $MaxFileSizeConverted"

# SIG # Begin signature block
# MIIpGgYJKoZIhvcNAQcCoIIpCzCCKQcCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCVXEG4ejFFtQ5d
# UEfm9+UIn91uZ74Y+sVuuYNDrkEKF6CCEgowggVvMIIEV6ADAgECAhBI/JO0YFWU
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
# Yur4z3eWEsKUoPdFAoiizb7CddijTOsNvxYNf0XEg5Ek1gTSMYIWZjCCFmICAQEw
# aDBUMQswCQYDVQQGEwJHQjEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSswKQYD
# VQQDEyJTZWN0aWdvIFB1YmxpYyBDb2RlIFNpZ25pbmcgQ0EgUjM2AhA1nosluv9R
# C3xO0e22wmkkMA0GCWCGSAFlAwQCAQUAoHwwEAYKKwYBBAGCNwIBDDECMAAwGQYJ
# KoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQB
# gjcCARUwLwYJKoZIhvcNAQkEMSIEIIvMkLPwfTIxD70SDJhiBORGmlby3UIHqX7p
# JFuDdfVKMA0GCSqGSIb3DQEBAQUABIICAGLDUPCVGcT6KdTpuM+bOGhtEmW7/3jS
# +g2MVH2bkLnuIx28sCFYgGKtAD7NQUZRhnscNxHmMpxRYGZ7iptI1Cl6aevbwwOA
# KST3cGipvx24FPn0EuOsiLxYbbkvLwwI21F4HKAwqfJAHDvAHvmG48C0p60HzhGk
# 3+Wck1BAIhrElaijHuqfG6mY3bz7M/4D7P6Y5KWkATzmU+M1S3xPAs8tFR84/EUB
# F5em90ULmlvmq7Q4Qzip1r89ljUjvDFI4tUZIw7E4vpVyIl9rEZh7Mh6tgHjs5Zj
# nubfbM91IDTC/JPTRLrJ3tBCL31yJzIa6/QomclxUf6lwrWILLSGUr3BPM83mhjn
# wK/Jt0VuISsBfdefr8giYljqMK/9+AxdiAbHeZOaIeJcwNe9SgLAkRDSpzFtzPGU
# FZJN1kCF/2W5+lM7yHzK+4PWBwB8F+VjSzqSciIMfNCv4OncWCUhDmWTnOua4Z54
# uOz9fs5ygfQ2hrVivqC044mwX8V12Kn+yi0oiSRR/K2mjm0myulI4HmHBXw2dkDz
# Cj5EDqjY/dCYTuFWhdRPOSby40J664C2ZJc53fdoIMJKh8PeBeOGxWUPHDMJFDou
# gRoEPwEwrRlYmDiibWRJXz9yXUURwv24pefLT5/pATVcwdE401RITmOLrNykp8sC
# aa8Q8m1EOAi1oYITUTCCE00GCisGAQQBgjcDAwExghM9MIITOQYJKoZIhvcNAQcC
# oIITKjCCEyYCAQMxDzANBglghkgBZQMEAgIFADCB8AYLKoZIhvcNAQkQAQSggeAE
# gd0wgdoCAQEGCisGAQQBsjECAQEwMTANBglghkgBZQMEAgEFAAQgOWMiMh0hpEsx
# DjCuqwDCiSVoh2Rg8vTeGEgMQ3j5qYoCFQDG2MOFasLdyYmZmErYEehQaJ7vPxgP
# MjAyMjA5MjgxNDI2NTJaoG6kbDBqMQswCQYDVQQGEwJHQjETMBEGA1UECBMKTWFu
# Y2hlc3RlcjEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSwwKgYDVQQDDCNTZWN0
# aWdvIFJTQSBUaW1lIFN0YW1waW5nIFNpZ25lciAjM6CCDeowggb2MIIE3qADAgEC
# AhEAkDl/mtJKOhPyvZFfCDipQzANBgkqhkiG9w0BAQwFADB9MQswCQYDVQQGEwJH
# QjEbMBkGA1UECBMSR3JlYXRlciBNYW5jaGVzdGVyMRAwDgYDVQQHEwdTYWxmb3Jk
# MRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxJTAjBgNVBAMTHFNlY3RpZ28gUlNB
# IFRpbWUgU3RhbXBpbmcgQ0EwHhcNMjIwNTExMDAwMDAwWhcNMzMwODEwMjM1OTU5
# WjBqMQswCQYDVQQGEwJHQjETMBEGA1UECBMKTWFuY2hlc3RlcjEYMBYGA1UEChMP
# U2VjdGlnbyBMaW1pdGVkMSwwKgYDVQQDDCNTZWN0aWdvIFJTQSBUaW1lIFN0YW1w
# aW5nIFNpZ25lciAjMzCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAJCy
# cT954dS5ihfMw5fCkJRy7Vo6bwFDf3NaKJ8kfKA1QAb6lK8KoYO2E+RLFQZeaoog
# NHF7uyWtP1sKpB8vbH0uYVHQjFk3PqZd8R5dgLbYH2DjzRJqiB/G/hjLk0NWesfO
# A9YAZChWIrFLGdLwlslEHzldnLCW7VpJjX5y5ENrf8mgP2xKrdUAT70KuIPFvZgs
# B3YBcEXew/BCaer/JswDRB8WKOFqdLacRfq2Os6U0R+9jGWq/fzDPOgNnDhm1fx9
# HptZjJFaQldVUBYNS3Ry7qAqMfwmAjT5ZBtZ/eM61Oi4QSl0AT8N4BN3KxE8+z3N
# 0Ofhl1tV9yoDbdXNYtrOnB786nB95n1LaM5aKWHToFwls6UnaKNY/fUta8pfZMdr
# KAzarHhB3pLvD8Xsq98tbxpUUWwzs41ZYOff6Bcio3lBYs/8e/OS2q7gPE8PWsxu
# 3x+8Iq+3OBCaNKcL//4dXqTz7hY4Kz+sdpRBnWQd+oD9AOH++DrUw167aU1ymeXx
# Mi1R+mGtTeomjm38qUiYPvJGDWmxt270BdtBBcYYwFDk+K3+rGNhR5G8RrVGU2zF
# 9OGGJ5OEOWx14B0MelmLLsv0ZCxCR/RUWIU35cdpp9Ili5a/xq3gvbE39x/fQnuq
# 6xzp6z1a3fjSkNVJmjodgxpXfxwBws4cfcz7lhXFAgMBAAGjggGCMIIBfjAfBgNV
# HSMEGDAWgBQaofhhGSAPw0F3RSiO0TVfBhIEVTAdBgNVHQ4EFgQUJS5oPGuaKyQU
# qR+i3yY6zxSm8eAwDgYDVR0PAQH/BAQDAgbAMAwGA1UdEwEB/wQCMAAwFgYDVR0l
# AQH/BAwwCgYIKwYBBQUHAwgwSgYDVR0gBEMwQTA1BgwrBgEEAbIxAQIBAwgwJTAj
# BggrBgEFBQcCARYXaHR0cHM6Ly9zZWN0aWdvLmNvbS9DUFMwCAYGZ4EMAQQCMEQG
# A1UdHwQ9MDswOaA3oDWGM2h0dHA6Ly9jcmwuc2VjdGlnby5jb20vU2VjdGlnb1JT
# QVRpbWVTdGFtcGluZ0NBLmNybDB0BggrBgEFBQcBAQRoMGYwPwYIKwYBBQUHMAKG
# M2h0dHA6Ly9jcnQuc2VjdGlnby5jb20vU2VjdGlnb1JTQVRpbWVTdGFtcGluZ0NB
# LmNydDAjBggrBgEFBQcwAYYXaHR0cDovL29jc3Auc2VjdGlnby5jb20wDQYJKoZI
# hvcNAQEMBQADggIBAHPa7Whyy8K5QKExu7QDoy0UeyTntFsVfajp/a3Rkg18PTag
# adnzmjDarGnWdFckP34PPNn1w3klbCbojWiTzvF3iTl/qAQF2jTDFOqfCFSr/8R+
# lmwr05TrtGzgRU0ssvc7O1q1wfvXiXVtmHJy9vcHKPPTstDrGb4VLHjvzUWgAOT4
# BHa7V8WQvndUkHSeC09NxKoTj5evATUry5sReOny+YkEPE7jghJi67REDHVBwg80
# uIidyCLxE2rbGC9ueK3EBbTohAiTB/l9g/5omDTkd+WxzoyUbNsDbSgFR36bLvBk
# +9ukAzEQfBr7PBmA0QtwuVVfR745ZM632iNUMuNGsjLY0imGyRVdgJWvAvu00S6d
# OHw14A8c7RtHSJwialWC2fK6CGUD5fEp80iKCQFMpnnyorYamZTrlyjhvn0boXzt
# VoCm9CIzkOSEU/wq+sCnl6jqtY16zuTgS6Ezqwt2oNVpFreOZr9f+h/EqH+noUgU
# kQ2C/L1Nme3J5mw2/ndDmbhpLXxhL+2jsEn+W75pJJH/k/xXaZJL2QU/bYZy06LQ
# wGTSOkLBGgP70O2aIbg/r6ayUVTVTMXKHxKNV8Y57Vz/7J8mdq1kZmfoqjDg0q23
# fbFqQSduA4qjdOCKCYJuv+P2t7yeCykYaIGhnD9uFllLFAkJmuauv2AV3Yb1MIIG
# 7DCCBNSgAwIBAgIQMA9vrN1mmHR8qUY2p3gtuTANBgkqhkiG9w0BAQwFADCBiDEL
# MAkGA1UEBhMCVVMxEzARBgNVBAgTCk5ldyBKZXJzZXkxFDASBgNVBAcTC0plcnNl
# eSBDaXR5MR4wHAYDVQQKExVUaGUgVVNFUlRSVVNUIE5ldHdvcmsxLjAsBgNVBAMT
# JVVTRVJUcnVzdCBSU0EgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkwHhcNMTkwNTAy
# MDAwMDAwWhcNMzgwMTE4MjM1OTU5WjB9MQswCQYDVQQGEwJHQjEbMBkGA1UECBMS
# R3JlYXRlciBNYW5jaGVzdGVyMRAwDgYDVQQHEwdTYWxmb3JkMRgwFgYDVQQKEw9T
# ZWN0aWdvIExpbWl0ZWQxJTAjBgNVBAMTHFNlY3RpZ28gUlNBIFRpbWUgU3RhbXBp
# bmcgQ0EwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDIGwGv2Sx+iJl9
# AZg/IJC9nIAhVJO5z6A+U++zWsB21hoEpc5Hg7XrxMxJNMvzRWW5+adkFiYJ+9Uy
# UnkuyWPCE5u2hj8BBZJmbyGr1XEQeYf0RirNxFrJ29ddSU1yVg/cyeNTmDoqHvzO
# WEnTv/M5u7mkI0Ks0BXDf56iXNc48RaycNOjxN+zxXKsLgp3/A2UUrf8H5VzJD0B
# KLwPDU+zkQGObp0ndVXRFzs0IXuXAZSvf4DP0REKV4TJf1bgvUacgr6Unb+0ILBg
# frhN9Q0/29DqhYyKVnHRLZRMyIw80xSinL0m/9NTIMdgaZtYClT0Bef9Maz5yIUX
# x7gpGaQpL0bj3duRX58/Nj4OMGcrRrc1r5a+2kxgzKi7nw0U1BjEMJh0giHPYla1
# IXMSHv2qyghYh3ekFesZVf/QOVQtJu5FGjpvzdeE8NfwKMVPZIMC1Pvi3vG8Aij0
# bdonigbSlofe6GsO8Ft96XZpkyAcSpcsdxkrk5WYnJee647BeFbGRCXfBhKaBi2f
# A179g6JTZ8qx+o2hZMmIklnLqEbAyfKm/31X2xJ2+opBJNQb/HKlFKLUrUMcpEmL
# QTkUAx4p+hulIq6lw02C0I3aa7fb9xhAV3PwcaP7Sn1FNsH3jYL6uckNU4B9+rY5
# WDLvbxhQiddPnTO9GrWdod6VQXqngwIDAQABo4IBWjCCAVYwHwYDVR0jBBgwFoAU
# U3m/WqorSs9UgOHYm8Cd8rIDZsswHQYDVR0OBBYEFBqh+GEZIA/DQXdFKI7RNV8G
# EgRVMA4GA1UdDwEB/wQEAwIBhjASBgNVHRMBAf8ECDAGAQH/AgEAMBMGA1UdJQQM
# MAoGCCsGAQUFBwMIMBEGA1UdIAQKMAgwBgYEVR0gADBQBgNVHR8ESTBHMEWgQ6BB
# hj9odHRwOi8vY3JsLnVzZXJ0cnVzdC5jb20vVVNFUlRydXN0UlNBQ2VydGlmaWNh
# dGlvbkF1dGhvcml0eS5jcmwwdgYIKwYBBQUHAQEEajBoMD8GCCsGAQUFBzAChjNo
# dHRwOi8vY3J0LnVzZXJ0cnVzdC5jb20vVVNFUlRydXN0UlNBQWRkVHJ1c3RDQS5j
# cnQwJQYIKwYBBQUHMAGGGWh0dHA6Ly9vY3NwLnVzZXJ0cnVzdC5jb20wDQYJKoZI
# hvcNAQEMBQADggIBAG1UgaUzXRbhtVOBkXXfA3oyCy0lhBGysNsqfSoF9bw7J/Ra
# oLlJWZApbGHLtVDb4n35nwDvQMOt0+LkVvlYQc/xQuUQff+wdB+PxlwJ+TNe6qAc
# Jlhc87QRD9XVw+K81Vh4v0h24URnbY+wQxAPjeT5OGK/EwHFhaNMxcyyUzCVpNb0
# llYIuM1cfwGWvnJSajtCN3wWeDmTk5SbsdyybUFtZ83Jb5A9f0VywRsj1sJVhGbk
# s8VmBvbz1kteraMrQoohkv6ob1olcGKBc2NeoLvY3NdK0z2vgwY4Eh0khy3k/ALW
# PncEvAQ2ted3y5wujSMYuaPCRx3wXdahc1cFaJqnyTdlHb7qvNhCg0MFpYumCf/R
# oZSmTqo9CfUFbLfSZFrYKiLCS53xOV5M3kg9mzSWmglfjv33sVKRzj+J9hyhtal1
# H3G/W0NdZT1QgW6r8NDT/LKzH7aZlib0PHmLXGTMze4nmuWgwAxyh8FuTVrTHurw
# ROYybxzrF06Uw3hlIDsPQaof6aFBnf6xuKBlKjTg3qj5PObBMLvAoGMs/FwWAKjQ
# xH/qEZ0eBsambTJdtDgJK0kHqv3sMNrxpy/Pt/360KOE2See+wFmd7lWEOEgbsau
# sfm2usg1XTN2jvF8IAwqd661ogKGuinutFoAsYyr4/kKyVRd1LlqdJ69SK6YMYIE
# LTCCBCkCAQEwgZIwfTELMAkGA1UEBhMCR0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFu
# Y2hlc3RlcjEQMA4GA1UEBxMHU2FsZm9yZDEYMBYGA1UEChMPU2VjdGlnbyBMaW1p
# dGVkMSUwIwYDVQQDExxTZWN0aWdvIFJTQSBUaW1lIFN0YW1waW5nIENBAhEAkDl/
# mtJKOhPyvZFfCDipQzANBglghkgBZQMEAgIFAKCCAWswGgYJKoZIhvcNAQkDMQ0G
# CyqGSIb3DQEJEAEEMBwGCSqGSIb3DQEJBTEPFw0yMjA5MjgxNDI2NTJaMD8GCSqG
# SIb3DQEJBDEyBDDpGd42/C56zSNb3Snk1QF+Uv5DbukSkBU26c/i60WknqLMz+1P
# pUX7yCI1O2ffZnMwge0GCyqGSIb3DQEJEAIMMYHdMIHaMIHXMBYEFKs0ATqsQJcx
# nwga8LMY4YP4D3iBMIG8BBQC1luV4oNwwVcAlfqI+SPdk3+tjzCBozCBjqSBizCB
# iDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCk5ldyBKZXJzZXkxFDASBgNVBAcTC0pl
# cnNleSBDaXR5MR4wHAYDVQQKExVUaGUgVVNFUlRSVVNUIE5ldHdvcmsxLjAsBgNV
# BAMTJVVTRVJUcnVzdCBSU0EgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkCEDAPb6zd
# Zph0fKlGNqd4LbkwDQYJKoZIhvcNAQEBBQAEggIACOEB3yvD+XNV+VjkTdM1rqoS
# Wk5kFVfEihw9C9K1vJxLWNXRIhB2AUrtJn68H/gf8s63R8gwuKprGYTBbuyP2rCX
# +oXtPooLxAlXFns6h8jDhWomAvD+vC1R3VDNvFR+wDf1yv6ksT6WS9/zaVx6r7dk
# 7DP9yVD7RXXDCVCycdsqN+QjJN5P0v+1b2qgsg/cQwFvpXRZ468GqP/HykO+hIuU
# LcGii00NwkkvHLeI+/Xx6ybypzib0CKCcA+sRBA5VwXJOYih9oldzMPzBvFBKaeX
# H/FlfAjeb+OzkAG6A09rV92VOBvpO+4Y7w7sU50b+a6FwNtUweTxgplg5tE1VXv+
# kdrxYrpqp1OvdQWL19EaTmRjFwgGO7pRisTrK/B8TLCEsSdsc4sO2hTuDRFVt1pL
# vMWEwwUQXB2ZXFaij/l4/ELn4ZbtFEUNCmFmG+BmUpD7LmCFeuPREnQ2IHIX15Pd
# gJMuv7hjhl4xo8E4rct0WUcuUrOmMs32MEKUmoqR6+N1IfhmTNg4/hYaWVuJIK/Z
# NYH9YdUZSN84FZMUIGKSB1IJqfY1/oGnWTEq3Bq/XTgkb4YsrhPmZGIL/Be613lH
# 9ZjhP3hIPq0gOqCv/KSjvlfFUlhm4C1rmSTaZy/MdY6Mzjo2VA+xJquPQ0k3WHM4
# EtbfDlNGaOqQeG9tzBE=
# SIG # End signature block