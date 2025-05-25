function Register-KeepAwake {
    <#
    .SYNOPSIS
    registers a scheduled job to run Start-KeepAwake at user login
    .DESCRIPTION
    registers a scheduled job to run Start-KeepAwake at user login.  Allows control over the Start-KeepAwake settings as well as some scheduled job settings.

    #>
    [CmdletBinding()]
    param ()

    # check if we're running as admin and quit if not

    $IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
    if ($IsAdmin) {
        # get the currently logged in user in case the PowerShell session was elevated via a different username than the one logged in to the computer
        $UserName = (Get-CimInstance -Class Win32_ComputerSystem).Username
        $ActionArgs = 'powershell.exe -NoLogo -NonInteractive -NoProfile -WindowStyle Hidden -Command "& {. "C:\Scripts\github\EsPreSso\source\Public\Start-KeepAwake.ps1"; Start-KeepAwake -PowerPlanMode}"'
        $TaskSettings = @{
                    Action = $(New-ScheduledTaskAction -Execute "Conhost.exe" -Argument $ActionArgs)
                    Principal = $(New-ScheduledTaskPrincipal -UserId $Username -LogonType Interactive)
                    TaskName = "esPreSso"
                    TaskPath = "\Microsoft\Windows\PowerShell\ScheduledJobs\"
                    Trigger = $(New-ScheduledTaskTrigger -AtLogOn -User $UserName)
                }
        $ExistingTask = Get-KeepAwake
        if ($ExistingTask) {
            Remove-KeepAwake
        }
        Register-ScheduledTask @TaskSettings
    } else {
        Write-Warning "Registering a scheduled task requires elevation. Please re-run PowerShell and 'run as administrator' and try again."
    }
}