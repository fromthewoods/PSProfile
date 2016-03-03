If (-not (Test-Path Env:\github_shell))
{
    #region Snippet Manager
    $snippetMgr = @{ Path = 'C:\Program Files (x86)\SnippetManager4\'
                     Bat  = 'Start__SnippetManager.cmd'
                     PS   = 'SnipMan_4.ps1' }
    If (Test-Path $snippetMgr.Path)
    {
        $psprocs = Get-Process -Name powershell -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowTitle -like '*SnippetManager*' -or $_.MainWindowTitle -eq ''}
        If ($psprocs)
        {
            Write-Host 'Snippet Manager is loaded.'
        }
        Else
        {
            Write-Host 'Loading Snippet Manager...'
            Push-Location
            Set-Location -Path $snippetMgr.Path
            Start-Process -FilePath powershell.exe -ArgumentList "-sta -noprofile -windowstyle hidden -File `"$($snippetMgr.path)\$($snippetMgr.PS)`""
            Pop-Location
        }
    }
    Else { Write-Host "Snippet Manager not found at $($snippetMgr.Path)" }
    #endregion

    #region Load Modules
    $modulelist = @('Pester',
                    'D:\Git\Write-Log\Write-Log.psd1')

    Foreach ($module in $modulelist) {
        Try
        {
            Import-Module $module -Force -ErrorAction SilentlyContinue
            Write-Host "Loaded module: $module"
        }
        Catch
        {
            Write-Host "Failed to load module: $module" -ForegroundColor Red
        }
    }
    #endregion
}