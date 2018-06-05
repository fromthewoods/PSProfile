#Requires -Version 5.0
[cmdletBinding()]
Param ( $ErrorActionPreference = 'Stop' )

# Trust the PowerShellGallery repo so we can install stuff from it
If ((Get-PSRepository -Name PSGallery).InstallationPolicy -eq 'Untrusted') {
  Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
}

# Install and/or load Pscx for later use
If (-not(Get-Module -Name Pscx -ListAvailable -ErrorAction SilentlyContinue -Verbose:$false)) { Install-Module -Name Pscx }
Import-Module -Name Pscx -Verbose:$false

# Verify OneDrive is available
$OneDrivePath = (Get-ItemProperty -Path HKCU:\Software\Microsoft\OneDrive -Name UserFolder).UserFolder
If (-not (Test-Path -Path $OneDrivePath)) { Throw "OneDrive could not be found at: $OneDrivePath" }

# Specify PowerShell profiles to link to OneDrive
$PSProfiles = @('Microsoft.PowerShell_profile',
  'Microsoft.PowerShellISE_profile',
  'Microsoft.VSCode_profile')

# Find the path to Documents, which must be found in the registry in case redirection is used.
$pathToDocuments = (Get-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -Name Personal).Personal
$pathToProfiles = "$pathToDocuments\WindowsPowerShell\"

# Link local PowerShell profiles to OneDrive
foreach ($file in $PSProfiles) {
  $localProfile = "$pathToProfiles\$file.ps1"
  If ((Test-Path -Path $localProfile) -and (Get-Item -Path $localProfile -ErrorAction SilentlyContinue).LinkType -like 'SymbolicLink') {
    Write-Verbose "$file is a symlink. Removing..."
    Remove-Item $localProfile
  }
  Else {
    Write-Verbose "$file already exists. Backing up..."
    Rename-Item -Path $localProfile -NewName "$pathToProfiles\$file-backup.ps1" -Force -ErrorAction SilentlyContinue
  }
  New-Symlink -LiteralPath $localProfile -TargetPath "$OneDrivePath\WindowsPowerShell\$file.ps1" | Out-Null
  Write-Verbose "Sym linked $localProfile to $OneDrivePath\WindowsPowerShell\$file.ps1"
}

# Link local VSCode settings to OneDrive
class VSCodeSettings {
  [string]$Name
  [TypeOfItem]$Type
  [LinkType]$LinkType
  [string]$ItemPath
  VSCodeSettings ([string]$Name, [TypeOfItem]$Type, [LinkType]$LinkType, [string]$ItemPath) {
    $this.Name = $Name
    $this.Type = $Type
    $this.LinkType = $LinkType
    $this.ItemPath = $ItemPath
  }
}

enum TypeOfItem {
  File
  Dir
}

enum LinkType {
  Junction
  SymLink
}

# Specify each VSCode file/dir to link to OneDrive
$VSCodeFiles = @(
  [VSCodeSettings]::new('Snippets', 'Dir', 'Junction', '\snippets'),
  [VSCodeSettings]::new('Keybindings', 'File', 'SymLink', '\keybindings.json'),
  [VSCodeSettings]::new('Settings', 'File', 'SymLink', '\settings.json')
)

# Enumerate each VSCode settings path.
$VSCodePaths = @("$env:APPDATA\Code\User\", "$env:APPDATA\Code - Insiders\User\")

foreach ($VSCodePath in $VSCodePaths) {
  foreach ($item in $VSCodeFiles) {
    If (Test-Path -Path $VSCodePath) {
      $localPath = "$VSCodePath{0}" -f $item.ItemPath 
      $remotepath = "$OneDrivePath\vscode\{0}" -f $item.ItemPath

      # Detect and backup/cleanup existing files
      If ((Test-Path -Path $localPath) -and ((Get-Item -Path $localPath -ErrorAction SilentlyContinue).LinkType -like 'Junction' -or `
          (Get-Item -Path $localPath -ErrorAction SilentlyContinue).LinkType -like 'SymbolicLink')) {
        Write-Verbose "$localPath is a link. Removing..."
        Remove-Item -Path $localPath -Force -Recurse
      }
      ElseIf (Test-Path -Path $localPath) {
        Write-Verbose "$localPath exists. Backing up."
        Rename-Item -Path $localPath -NewName "$localPath.Backup" -Force
      }

      # Perfom linking
      If ($item.LinkType -eq 'Junction') { 
        New-Junction -LiteralPath $localPath -TargetPath $remotepath | Out-Null
        Write-Verbose "Junction linked $localPath to $remotepath"
      }
      Else { 
        New-Symlink  -LiteralPath $localPath -TargetPath $remotepath | Out-Null
        Write-Verbose "Sym linked $localPath to $remotepath"
      }
    }
  }
}

Write-Verbose "========================================="
Write-Verbose "= SETUP COMPLETE. RELAUNCH POWERSHELL!! ="
Write-Verbose "========================================="