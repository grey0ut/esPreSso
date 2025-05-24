function Get-KeepAwake {
    <#
    .SYNOPSIS
    Checks the registered scheduled tasks for the esPreSso job that runs Start-KeepAwake
    .DESCRIPTION
    Checks the registered scheduled tasks for the esPreSso job that runs Start-KeepAwake and return an object representing its settings
    .EXAMPLE
    PS> Get-KeepAwake

    TaskPath                                       TaskName                          State
    --------                                       --------                          -----
    \Microsoft\Windows\PowerShell\ScheduledJobs\   esPreSso                          Ready

    #>
    [CmdletBinding()]
    param ()

    $TaskName = "esPreSso"
    $TaskPath = "\Microsoft\Windows\PowerShell\ScheduledJobs\"
    try {
        Get-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -ErrorAction Stop
    } catch {
        Write-Warning "esPreSso scheduled task not found"
    }
}
