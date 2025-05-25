<div align='center'>
<img src='Assets/espresso.svg' />
</div>

# esPreSso
A PowerShell module for Windows that attempts to keep your computer awake by sending key-presses.  Inspired by the program 'Caffeine' and the numerous PowerShell variations that exist out there.

The primary method that is used for keeping the computer awake is to send a key press of `Shift+F15` every 60 seconds.  This generally doesn't impact anything but can cause issues with Putty sessions, PowerPoint, Google Docs or Smartsheet.  By periodically sending a key press Windows, and many other programs, will think that the computer is in use and will **not** activate the lock screen or sleep.

Additionally a second method is provided via the `-PowerControl` parameter that registers the current PowerShell process as keeping the System and Display in use via the Windows API.  This is still being tested but seems to work at preventing screen lock and sleep even though there is no apparent user activity.

## Installation
esPreSso is a Windows only module and will not work on other operating systems.  To install esPreSso, use Install-Module to get it from the PowerShell Gallery.
```Powershell
PS> Install-Module esPreSso
```
The module can be installed, and work, by a standard user without admin permissions.  If you wish to use the Register/Remove-KeepAwake functions then you will have to run Powershell as an administrator.  If you have a separate account for administrator permissions and want to use the Register/Remove-KeepAwake functions then install esPreSso as an administrator scoped for all users.

## Start-KeepAwake
The primary function for this module is Start-KeepAwake.  It needs to be ran from a PowerShell session and the terminal window needs to remain open for it to continue to work.  It produces no output, but if called with -Verbose it provides some details.

```PowerShell
PS> Start-KeepAwake -Verbose
VERBOSE: Defaulting to indefinite runtime
VERBOSE: Keeping computer awake by sending 'Shift + F15' every 60 seconds
```
Here you can see that by default it will run indefinitely and simulate pressing 'Shift+F15' every 60 seconds.  You can also specify a different interval for the key press.
```PowerShell
PS> Start-KeepAwake -Interval 300 -Verbose
VERBOSE: Defaulting to indefinite runtime
VERBOSE: Keeping computer awake by sending 'Shift + F15' every 300 seconds
```
You can manually specify how long you want Start-KeepAwake to run with the `Hours` and/or `Minutes` parameters as well.
```PowerShell
PS> Start-KeepAwake -Hours 2 -Interval 10 -Verbose
VERBOSE: Adding 2 hours of duration
VERBOSE: Total duration is 120 minutes
VERBOSE: Keeping computer awake by sending 'Shift + F15' every 10 seconds
VERBOSE: 120.00 minutes remaining
VERBOSE: 119.83 minutes remaining
VERBOSE: 119.67 minutes remaining
VERBOSE: 119.50 minutes remaining
VERBOSE: 119.33 minutes remaining
VERBOSE: 119.17 minutes remaining
VERBOSE: 119.00 minutes remaining
VERBOSE: 118.83 minutes remaining
VERBOSE: 118.67 minutes remaining
VERBOSE: 118.50 minutes remaining
...
```
Here you can see the total duration in minutes is represented and based on the interval a remainder is displayed after each key press.

Additionally you can also specify a date time you would like Start-KeepAwake to run *until*.
```PowerShell
PS> Start-KeepAwake -Until "4:00 PM" -Verbose
VERBOSE: Stopping time provided of: 4:00 PM
VERBOSE: Adding 18.0951080466667 minutes of duration
VERBOSE: Total duration is 18 minutes
VERBOSE: Keeping computer awake by sending 'Shift + F15' every 60 seconds
VERBOSE: 18.00 minutes remaining
```
The `-Until` parameter converts input to a DateTime object allowing you to provide string text in a variety of formats and still get the correct time out of it.  E.g. `13:00`, `2:00 am`, `5/26/25 12:00 pm` are all acceptable.

### Aliases
Start-KeepAwake also ships with two aliases for it built in: `nosleep` and `ka`.  At its simplest this means you could open PowerShell and type:
```PowerShell
PS> ka

```
and Start-KeepAwake would be running indefinitely.

### PowerControl method
Start-KeepAwake can also prevent sleep and screen lock by leveraging the Windows API to register the PowerShell process as using the display and system.
```PowerShell
PS> Start-KeepAwake -PowerControl -Verbose
VERBOSE: Preventing sleep via PowerCtrl
```
Then press `Ctrl+c` to cancel the running command and the total execution will look like this:
```PowerShell
PS> Start-KeepAwake -PowerControl -Verbose
VERBOSE: Preventing sleep via PowerCtrl
VERBOSE: Removing PowerCtrl

```
If you close the PowerShell window instead of using `Ctrl+c` the process will remain and the computer will continue to stay awake.  You have to find the process ID for that instance of PowerShell and stop it.

## esPreSso as a scheduled task
I don't know who needs this, but if you want Start-KeepAwake to run at user logon (for the current user) you can launch PowerShell with administrator privileges and use Register-KeepAwake.
```PowerShell
PS> Register-KeepAwake

TaskPath                                       TaskName                          State
--------                                       --------                          -----
\Microsoft\Windows\PowerShell\ScheduledJobs\   esPreSso                          Ready


```
This task can be ran on-dememand, or it will automatically run when the current user logs in.  If you're logged in as UserA but have to authenticate as UserB in a UAC prompt to perform actions with administrator permissions the scheduled task will *still* be configured to run at the logon of UserA.

The scheduled task will run `Start-KeepAwake -PowerControl` in a hidden PowerShell window and prevent sleep and lock screen but will not make the user session appear as active.  There is currently no way to stop it once it's started running.  You can remove the scheduled task and logout/login and that will stop it.
```PowerShell
PS> Remove-KeepAwake
```
This will remove the previously created scheduled task.
```PowerShell
PS> Get-KeepAwake

TaskPath                                       TaskName                          State
--------                                       --------                          -----
\Microsoft\Windows\PowerShell\ScheduledJobs\   esPreSso                          Ready

```
If the scheduled task is present Get-KeepAwake will return the Scheduled Task object.

## Made With Sampler
This project was made using [Sampler Module](https://github.com/gaelcolas/Sampler)
See their [video presentation](https://youtu.be/tAUCWo88io4?si=jq0f7omwll1PtUsN) from the PowerShell summit for a great demonstration.