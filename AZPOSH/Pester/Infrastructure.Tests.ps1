$computerName = 'CHD1SCCM01.eps.local'
$username = 'eps\adm_jbaltrus'

if ($credential -eq $null) {
  $credential = Get-Credential -UserName $username -Message "Please enter password for $username"
}

Import-Module ServerManager

Write-Host 'Network test' -ForegroundColor Cyan
$nettest = Test-NetConnection -ComputerName $computerName -Port 80

Write-Host 'PSSession' -ForegroundColor Cyan
$session = New-PSSession -ComputerName $computerName -Credential $credential

Write-Host 'Windows Features' -ForegroundColor Cyan
$iis = Get-WindowsFeature -ComputerName $computerName -Name 'Web-*' -Credential $credential

Write-Host 'MP Check' -ForegroundColor Cyan
$mpXml = [xml](Invoke-WebRequest -Uri "http://$computerName/sms_mp/.sms_aut?mplist").Content

Write-Host 'SMS_EXECUTIVE' -ForegroundColor Cyan
$svc = Get-Service -Name SMS_EXECUTIVE -ComputerName $computerName -ErrorAction SilentlyContinue

Write-Host '====== Begin Tests ======' -ForegroundColor Yellow
Describe -Name 'SCCM server tests' {
  Context -Name 'Network' {
    It 'should be pingable' {
      $nettest.PingSucceeded | Should Be 'true'
    }
    It 'should be listening on port 443' {
      $nettest.TcpTestSucceeded | Should Be 'true'
    }
  }
  Context -Name 'IIS' {
    It 'should have the remote mgmt service' {
      ($iis | Where Name -like 'Web-Mgmt-Service').Installed | Should Be 'true'
    }
    It 'should not have the legacy console' {
      ($iis | Where Name -like 'Web-Lgcy-Mgmt-Console').Installed | Should Be 'False'
    }
  }
  Context 'Management Point' {
    It 'should have a healthy MP' {
      $mpXml.MPList.MP.Name | Should BeExactly $computerName
    }
    It 'should have smsexec service' {
      $svc.Name | Should Be 'SMS_EXECUTIVE'
    }
    It 'should have running smsexec service' {
      $svc.Status | Should Be 'Running'
    }
  }
}