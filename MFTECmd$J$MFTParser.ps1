<#
	.SYNOPSIS
		Searches for the $J and $MFT and then parses them together with MFTECmd to generate data within the ParentPath column in the CSV output. Please place this script within .\KAPE\Modules\bin in order for it to work properly. There, your MFTECmd.exe binary should reside, as well.

	.DESCRIPTION
		$J + $MFT = more verbose and useful $J CSV output with MFTECmd! This script will search recursively from the location you specify for $TargetFolder for $J and $MFT files. Please note, this MFTECmd command cannot handle multiple of each. Only one $J and one $MFT, ideally from the same system :)

	.PARAMETER TargetsFolder
		Please specify a folder that contains a $J and $MFT to be parsed by MFTECmd

	.PARAMETER OutputFolder
		Please specify where you want the parsed $J and $MFT CSV output to go

	.NOTES
		===========================================================================
		Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2022 v5.8.198
		Created on:   	20220117 @ 1945 UTC
		Created by:   	Andrew Rathbun
		===========================================================================
#>
param
(
	[Parameter(Mandatory = $true,
			   Position = 1)]
	[String]$TargetsFolder,
	[Parameter(Mandatory = $true,
			   Position = 2)]
	[String]$OutputFolder
)
# trying to get it so if someone specifies -KAPE, it'll just search for mftecmd.exe, but also, if someone doesn't specify -KAPE, they'll be prompted to provide full file path to mftecmd.exe
switch ($MFTECmd)
{
	"KAPE" {
		$MFTECmd = Get-ChildItem -Recurse -Path $PSScriptRoot -Include 'MFTECmd.exe'
	}
	"MFTECmd" {
		$MFTECmd = Read-Host -Prompt 'Please provide the full file path to MFTECmd.exe'
		Write-Host "MFTECmd.exe is located at the following location $MFTECmd"
	}
	
}

if (!(Test-Path -Path $OutputFolder))
{
	New-Item -Path $OutputFolder -ItemType "directory" | Out-Null
	while (!(Test-Path -Path $OutputFolder))
	{
		Start-Sleep -Milliseconds 100
	}
}

$MFT = Get-ChildItem -Recurse -Path $TargetsFolder -Include '$MFT'
$J = Get-ChildItem -Recurse -Path $TargetsFolder -Include '$J'

Start-Process -FilePath $MFTECmd -ArgumentList "-f $J -m $MFT --csv $OutputFolder"

# removing signature for purpose of editing code
