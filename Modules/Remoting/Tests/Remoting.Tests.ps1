$moduleName = 'Remoting'
Push-Location
Set-Location C:\Users\jbaltrus\OneDrive\WindowsPowerShell\Modules\Remoting\Tests
Import-Module ..\$moduleName.psd1 -Force

#region ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ MODULE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

InModuleScope -ModuleName $moduleName {
    Describe -Tags 'Unit' 'Enter-WinRM' {
        Context 'Primary Tests' {
            It 'should exist' {
                Get-Command Enter-WinRM -ErrorAction SilentlyContinue | Should Be Enter-WinRM
            }
            It 'should throw when an error is encountered' {
                Mock -CommandName Write-Verbose -MockWith { Throw 'Mocked' }
                { Enter-WinRM -ComputerName 'derp' } | Should Throw 'Mocked'
            }
        }
    }
}

Pop-Location
#endregion
