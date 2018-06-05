#Requires -Version 5.0
Try
{
    $mainProfile = '\Main_profile.ps1' 

    # Verify OneDrive is available
    $OneDrivePath = (Get-ItemProperty -Path HKCU:\Software\Microsoft\OneDrive -Name UserFolder).UserFolder
    If (Test-Path -Path $OneDrivePath\WindowsPowerShell) { 
        New-PSDrive -Name OneDrive -PSProvider FileSystem -Root $OneDrivePath -Description 'OneDrive Rocks!' | Out-Null
        Write-Host 'Created OneDrive:'
        $env:PSModulePath += ";OneDrive:\WindowsPowerShell\Modules"
        
        # Find the Documents path to load the PowerShell profiles
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