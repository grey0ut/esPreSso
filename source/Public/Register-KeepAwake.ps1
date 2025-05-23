function Register-KeepAwake {
    <#
    .SYNOPSIS
    registers a scheduled job to run Start-KeepAwake at user login
    .DESCRIPTION
    registers a scheduled job to run Start-KeepAwake at user login.  Allows control over the Start-KeepAwake settings as well as some scheduled job settings.

    #>
    #Requires -RunAsAdministrator
    [CmdletBinding()]
    param (

    )

    $JobOptions = New-ScheduledJobOption -HideInTaskScheduler
    $UserName = (Get-CimInstance -Class Win32_ComputerSystem).Username
    $JobTrigger = New-JobTrigger -AtLogOn -User $UserName  #$('{0}\{1}' -f [System.Environment]::UserDomainName, [System.Environment]::UserName)
    #$Credentials = [System.Management.Automation.PSCredential]::new($UserName,[System.Security.SecureString]::new())

    $Principal = New-ScheduledTaskPrincipal -UserId $UserName -LogonType Interactive
    $OptionSplat = $null
    $JobParams = foreach ($Key in $OptionSplat.GetEnumerator().Name) {
        if ($OptionSplat[$Key].GetType().Name -eq "Boolean") {
            '-{0}:${1}' -f $Key, $OptionSplat[$Key]
        } else {
            '-{0} {1}' -f $Key, $OptionSplat[$Key]
        }
    }
    $ActionArgs = '-NoLogo -NonInteractive -NoProfile -WindowStyle Minimized -Command "& {{. "C:\Scripts\Modules\EsPreSso\source\Public\Start-KeepAwake.ps1"; Start-KeepAwake {0}}}"' -f $($JobParams -join ' ')
    $ActionArgs = '-NoLogo -NonInteractive -NoProfile -WindowStyle Minimized -Command "& {{Start-Job -ScriptBlock {{. "C:\Scripts\Modules\EsPreSso\source\Public\Start-KeepAwake.ps1"; Start-KeepAwake {0}}}}}"' -f $($JobParams -join ' ')
    $TaskSettings = @{
                #Action = $(New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-f c:\scripts\testing\whoami.ps1")
                Action = $(New-ScheduledTaskAction -Execute "Powershell.exe" -Argument $ActionArgs
                Principal = $(New-ScheduledTaskPrincipal -UserId $Username)
                TaskName = "esPreSso"
                TaskPath = "\Microsoft\Windows\PowerShell\ScheduledJobs\"
                Trigger = $(New-ScheduledTaskTrigger -AtLogOn -User $UserName)
            }
    Register-ScheduledTask @TaskSettings
    $Job = Register-ScheduledJob -Name "esPreSso" -Trigger $JobTrigger -ScriptBlock {
        . "C:\Scripts\Modules\EsPreSso\source\Public\Start-KeepAwake.ps1"
        Start-KeepAwake -Hours 2 -Verbose
    }
    $ScheduledTask = Get-ScheduledTask -TaskName "esPreSso"
    Set-ScheduledTask -TaskName "esPreSso" -TaskPath $ScheduledTask.TaskPath -Principal $Principal
}