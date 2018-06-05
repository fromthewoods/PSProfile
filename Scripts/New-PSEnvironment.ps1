#Requires -Version 5.0
[cmdletBinding(SupportsShouldProcess = $true)]
Param ( $ErrorActionPreference = 'Stop' )

# Trust the PowerShellGallery repo so we can install stuff from it
If ((Get-PSRepository -Name PSGallery).InstallationPolicy -eq 'Untrusted') {
  Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
}

# Install and/or load Pscx for later use
If (-not(Get-Module -Name Pscx -ListAvailable -ErrorAction SilentlyContinue -Verbose:$false)) { Install-Module -Name Pscx }
Import-Module -Name Pscx -Verbose:$false

# Verify OneDrive is available
# $OneDrivePath = (Get-ItemProperty -Path HKCU:\Software\Microsoft\OneDrive -Name UserFolder).UserFolder
# If (-not (Test-Path -Path $OneDrivePath)) { Throw "OneDrive could not be found at: $OneDrivePath" }

# Discover the profiles configured in the git repo
$gitProfiles = Get-ChildItem -Path $PSScriptRoot\..\Profiles\*.ps1

# Find the path to Documents, which must be found in the registry in case redirection is used.
$pathToDocuments = (Get-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -Name Personal).Personal
$localProfilesDir = "$pathToDocuments\WindowsPowerShell\"

# Link local PowerShell profiles to git
foreach ($file in $gitProfiles) {
  $localProfile = "$localProfilesDir\$($file.Name)"
  If ((Test-Path -Path $localProfile) -and (Get-Item -Path $localProfile -ErrorAction SilentlyContinue).LinkType -like 'SymbolicLink') {
    If ($PSCmdlet.ShouldProcess($($file.Name))) {
      Write-Verbose "File [$($file.Name)] is a symlink. Removing..."
      Remove-Item -Path $localProfile
    }
    Else {
      Remove-Item -Path $localProfile -WhatIf
    }
  }
  Else {
    If ($PSCmdlet.ShouldProcess($($file.Name))) {
      Write-Verbose "File [$($file.Name)] already exists. Backing up..."
      Rename-Item -Path $localProfile -NewName "$localProfilesDir\$($file.Name)-backup.ps1" -Force -ErrorAction SilentlyContinue
    }
    Else {
      Rename-Item -Path $localProfile -NewName "$localProfilesDir\$($file.Name)-backup.ps1" -Force -ErrorAction SilentlyContinue -WhatIf
    }
  }

  If ($PSCmdlet.ShouldProcess($($file.Name))) {
    Write-Verbose "Sym linking [$localProfile] to [$($file.FullName)]."
    New-Symlink -LiteralPath $localProfile -TargetPath $file.FullName | Out-Null
  } Else {
    New-Symlink -LiteralPath $localProfile -TargetPath $file.FullName -WhatIf
  }
}

Write-Verbose "========================================="
Write-Verbose "= SETUP COMPLETE. RELAUNCH POWERSHELL!! ="
Write-Verbose "========================================="