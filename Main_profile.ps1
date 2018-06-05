#Requires -Version 5.0
$PsGalleryModulesToLoad += @('PSReadLine','Pscx','Pester')
$installedModules = Get-ChildItem -Path 'C:\Program Files\WindowsPowerShell\Modules'
#$installedModules += Get-ChildItem -Path '\\phxmain-fs01\user$\jbaltrus\Documents\WindowsPowerShell\Modules'

# Set the PowerShell Gellery repo to Trusted
If ((Get-PSRepository -Name PSGallery).InstallationPolicy -eq 'Untrusted') {
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted -Force
}

# Install ChocolateyGet Package Provider
If (-not (Get-PackageProvider -Name ChocolateyGet -ListAvailable -ErrorAction SilentlyContinue)) {
    Install-PackageProvider -Name ChocolateyGet
}
Import-PackageProvider -Name ChocolateyGet | Out-Null

# Create Documents drive
$documentsPath = (Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -Name Personal).Personal
If (Test-Path -Path $documentsPath) { 
    New-PSDrive -Name Documents -PSProvider FileSystem -Root $documentsPath | Out-Null
    Write-Host 'Created Documents:'
}
Else { Write-Host "Did not find $documentsPath." -ForegroundColor Yellow}

# Load or install all the modules
Foreach ($mod in $PsGalleryModulesToLoad) {
    $thisMod = $false
    $thisMod = $installedModules | Where-Object { $_.Name -like $mod }
    If ($thisMod) {
        Import-Module $thisMod.FullName -Force
        Write-Host "Loaded: $mod"
    }
    Else {
        Write-Host "Installing: $mod"
        If ((Get-WmiObject Win32_OperatingSystem).Version -like '6.1*') { Install-Module -Name $mod }
        Else { Install-Module -Name $mod -AllowClobber }
        Import-Module -Name $mod -Force
        Write-Host "Loaded: $mod"
    }
}

# Load specific modules that are only needed at work.
$DevOps = 'C:\source\EPS\DevOps Automation\Dev'
$DevOpsModules = $Devops + '\Modules'
$DevOpsProfile = $Devops + '\Modules\DeployExpress\DeployExpress\DeployExpress.psd1'
If (Test-Path $DevOps) {
    Import-Module $DevOpsProfile
    New-PSDrive -Name Code -PSProvider FileSystem -Root 'C:\source\EPS\DevOps Automation' | Out-Null
    $env:PSModulePath += ";$DevOpsModules"
}

Set-Location -Path OneDrive:\WindowsPowerShell
Write-Host 'Done!'

# Load the prompt
. OneDrive:\WindowsPowerShell\Prompt.ps1