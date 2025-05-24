function Register-KeepAwake {
    <#
    .SYNOPSIS
    registers a scheduled job to run Start-KeepAwake at user login
    .DESCRIPTION
    registers a scheduled job to run Start-KeepAwake at user login.  Allows control over the Start-KeepAwake settings as well as some scheduled job settings.

    #>
    #Requires -RunAsAdministrator
    [CmdletBinding()]
    param ()

    # get the currently logged in user in case the PowerShell session was elevated via a different username than the one logged in to the computer
    $UserName = (Get-CimInstance -Class Win32_ComputerSystem).Username
    $ActionArgs = '-NoLogo -NonInteractive -NoProfile -WindowStyle Hidden -Command "& {. "C:\Scripts\GitHub\EsPreSso\source\Public\Start-KeepAwake.ps1"; Start-KeepAwake -PowerPlanMode -Verbose}"'
    $TaskSettings = @{
                Action = $(New-ScheduledTaskAction -Execute "Powershell.exe" -Argument $ActionArgs)
                Principal = $(New-ScheduledTaskPrincipal -UserId $Username -LogonType Interactive)
                TaskName = "esPreSso"
                TaskPath = "\Microsoft\Windows\PowerShell\ScheduledJobs\"
                Trigger = $(New-ScheduledTaskTrigger -AtLogOn -User $UserName)
            }
    Register-ScheduledTask @TaskSettings
}