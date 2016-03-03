Try
{
    . D:\Git\PSProfile\PSProfile.ps1
}
Catch
{
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "$($_.InvocationInfo.PositionMessage.Split('+')[0])"
}

#region Load Modules
#$modulelist = @('PsISEProjectExplorer')
#
#Foreach ($module in $modulelist) {
#    Try
#    {
#        Import-Module $module -Force -ErrorAction SilentlyContinue
#        Write-Host "Loaded module: $module"
#    }
#    Catch
#    {
#        Write-Host "Failed to load module: $module" -ForegroundColor Red
#    }
#}
#endregion