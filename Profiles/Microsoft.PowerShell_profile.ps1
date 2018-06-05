#Requires -Version 5.0
Try
{
    $mainProfile = '\Main_profile.ps1' 
    $PsGalleryModulesToLoad = @('PowerShellCookBook')

    # Verify OneDrive is available
    $OneDrivePath = (Get-ItemProperty -Path HKCU:\Software\Microsoft\OneDrive -Name UserFolder).UserFolder
    If (Test-Path -Path $OneDrivePath\WindowsPowerShell) { 
        New-PSDrive -Name OneDrive -PSProvider FileSystem -Root $OneDrivePath -Description 'OneDrive Rocks!' | Out-Null
        Write-Host 'Created OneDrive:'
        $env:PSModulePath += ";OneDrive:\WindowsPowerShell\Modules"
        
        # Detect if Git is in the path and load it
        $pathArray = (Get-Item Env:\Path).Value.Split(';')
        If ($pathArray -like '*git*') { . OneDrive:\WindowsPowerShell\Scripts\Enable-Git.ps1 }
        
        # Load the main profile
        . OneDrive:\WindowsPowerShell\$mainProfile
    }
    Else {
        Throw "OneDrive could not be found at: $OneDrivePath"
    }
}
Catch
{
    Write-Host "ERROR: $($_.Exception.Message)"
    Write-Host "ERROR: $($_.InvocationInfo.PositionMessage.Split('+')[0])"
}
# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}
