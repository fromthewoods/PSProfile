function Enter-WinRM {
    <#
        .SYNOPSIS
            Establishes a PowerShell remote session with custom options
        .DESCRIPTION
            Long description
        .EXAMPLE
            Example here
    #>
    [CmdletBinding()]
    [OutputType([object])]
    Param (
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string]$ComputerName,

        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$false,
                   Position=1)]
        [pscredential]$Credential,

        [switch]$NoPrompt
    )
    
    Try {
        Write-Verbose "Connecting to $ComputerName"
        If ($Credential) {
            $session = New-PSSession -ComputerName $ComputerName -Credential $Credential
        }
        Else {
            $session = New-PSSession -ComputerName $ComputerName
        }
        $shortName = ($ComputerName -split '\.')[0]
        $promptScript = (Get-Command prompt).ScriptBlock
        $promptScript = "function prompt {    `$WinRMSession = `'[$shortName]`'; $promptScript }"
        Invoke-Command -Session $session -ScriptBlock {
            Invoke-Expression -Command $Using:promptScript
        }
        Enter-PSSession -Session $session
    }
    Catch {
        $message = $_.Exception.Message
        $position = $_.InvocationInfo.PositionMessage.Split('+')[0]
        Write-Verbose "ERROR: $message"
        Write-Verbose "ERROR: $position"
        Throw "$message $position"
    }
}