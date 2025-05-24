function Remove-KeepAwake {
    <#
    .SYNOPSIS
    Removes the esPreSso scheduled task from Task Scheduler
    .DESCRIPTION
    Unregisters the scheduled task created by Register-KeepAwake. There is no output.
    .EXAMPLE
    PS> Remove-KeepAwake
    #>
    #Requires -RunAsAdministrator
    [CmdletBinding()]
    param ()

    $ScheduledTask = Get-KeepAwake
    if ($ScheduledTask) {
        Write-Verbose "Removing scheduled task named $($ScheduledTask.TaskName) in $($ScheduledTask.TaskPath)"
        Unregister-ScheduledTask -InputObject $ScheduledTask -Confirm:$false
    }
}