Function Prompt {
    $promptChar = [char]955
    #$prompt = "PS $($promptChar * ($NestedPromptLevel + 1) ) "
    $prompt = "PS $($promptChar) "
    $currentLocation = $executionContext.SessionState.Path.CurrentLocation
    Write-Host ""
    $viConnection = ''
    
    If ($global:DefaultVIServer) {
        $viConnection = "[$(($global:DefaultVIServer.name).Split('.')[0])] "
        Write-Host $viConnection -NoNewline -ForegroundColor green
        $windowTitle = $viConnection + $currentLocation
    }
    ElseIf ($WinRMSession) {
        $windowTitle = $WinRMSession + $currentLocation
    }
    Else {
        $windowTitle = $currentLocation
    }
    $host.ui.RawUI.WindowTitle = $windowTitle

    Write-Host $currentLocation -ForegroundColor Cyan
    Return $prompt
}