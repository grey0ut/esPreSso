function Remove-KeepAwake {
    <#
    .SYNOPSIS
    Removes the esPreSso scheduled task from Task Scheduler
    .DESCRIPTION
    Unregisters the scheduled task created by Register-KeepAwake. There is no output.
    .EXAMPLE
    PS> Remove-KeepAwake
    #>
    [CmdletBinding()]
    param ()

    $ScheduledTask = Get-KeepAwake
    if ($ScheduledTask) {
        $IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
        if ($IsAdmin) {
            Write-Verbose "Removing scheduled task named $($ScheduledTask.TaskName) in $($ScheduledTask.TaskPath)"
            Unregister-ScheduledTask -InputObject $ScheduledTask -Confirm:$false
        } else {
            Write-Warning "Removing a scheduled task requires elevation. Please re-run PowerShell and 'run as administrator' and try again."
        }
    } else {
        Write-Warning "No scheduled task for esPreSso found"
    }
}