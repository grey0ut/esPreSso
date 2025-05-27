function Start-KeepAwake {
    <#
    .SYNOPSIS
    This function attempts to keep the computer awake by sending a key-press every 60 seconds (by default)
    .DESCRIPTION
    Using the WScript namespace to send keys this function will send a key combination of F15 every 60 seconds by default to keep the computer awake and preven the screensaver
    from activating.
    .PARAMETER Minutes
    Number of minutes to run the keep awake
    .PARAMETER Hours
    Number of hours to run the keep awake
    .PARAMETER Until
    A date time representing when to stop running the keep awake. Accepts common datetime formats
    .PARAMETER Interval
    The interval for how often a key press is sent. Default is 60 seconds and this should be fine for most scenarios.
    .PARAMETER Key
    Optionally can specify which keypress to send.  The default, and most widely tested is F15, but just about any key on the keyboard can be specified. Supports tab completion to see which keys can be selected
    .PARAMETER PowerControl
    Switch parameter that tells Start-KeepAwake to register a request via SetThreadExecutionState to keep the display awake and prevent sleep.
    Cancelled with Ctrl+C or other terminating signal.
    .EXAMPLE
    PS> Start-KeepAwake

    When ran with no parameters the function will attempt to keep the computer awake indefinitely until cancelled.
    .EXAMPLE
    PS> Start-KeepAwake -Until "3:00pm"

    will send a keypress of F15 every minute until 3:00 pm the same day
    .EXAMPLE
    PS> Start-KeepAwake -Key Shift -Interval 10

    will send a press of the 'shift' key every 10 seconds
    .EXAMPLE
    PS> Start-KeepAwake -PowerControl

    Will also attempt to keep the computer awake indefinitely but won't send any key presses.
    .NOTES
    Credit to marioraulperez for his class definition: https://github.com/marioraulperez/keep-windows-awake
    #>
    [CmdletBinding(DefaultParameterSetName = 'Manual')]
    [Alias("nosleep","ka")]
    Param(
        [Parameter(Position=1, ParameterSetName='Manual')]
        [Alias("m")]
        [Int32]$Minutes,
        [Parameter(Position=0, ParameterSetName='Manual')]
        [Alias("h")]
        [Int32]$Hours,
        [Parameter(ParameterSetName='Until')]
        [Alias("u")]
        [DateTime]$Until,
        [Parameter(ParameterSetName='Manual')]
        [Parameter(ParameterSetName='Until')]
        [ValidateRange(1,86400)]
        [Int32]$Interval = 60,
        [Parameter(ParameterSetName='Manual')]
        [Parameter(ParameterSetName='Until')]
        [ArgumentCompleter({
            param ($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
            $ValidValues = Get-Keys
            $ValidValues -like "$WordToComplete*"
        })]
        [ValidateScript({
            if ($_ -in (Get-Keys)) {
                $true
            } else {
                throw "$_ is not a valid key option"
            }
        })]
        [String]$Key = 'F15',
        [Parameter(ParameterSetName='PowerPlan')]
        [Switch]$PowerControl
    )

    if ($PowerControl) {
            try {
                $Definition = @"
using System;
using System.Runtime.InteropServices;

public class PowerCtrl {
    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern uint SetThreadExecutionState(uint esFlags);

    public static void PreventSleep() {
        // ES_CONTINUOUS | ES_SYSTEM_REQUIRED | ES_DISPLAY_REQUIRED
        SetThreadExecutionState(0x80000002 | 0x00000001 | 0x00000002);
    }

    public static void AllowSleep() {
        // ES_CONTINUOUS
        SetThreadExecutionState(0x80000000);
    }
}
"@
                Add-Type -Language CSharp -TypeDefinition $Definition
                Write-Verbose "Preventing sleep via PowerCtrl"
                $BackgroundJob = Start-Job -Name "esPreSso" -ScriptBlock {
                    Add-Type -Language CSharp -TypeDefinition $args[0]
                    [PowerCtrl]::PreventSleep()
                    while ($true) {
                        Start-Sleep -Seconds 60
                    }
                } -ArgumentList $Definition
                Wait-Job -Job $BackgroundJob
            } catch {
                Write-Error $_
            } finally {
                Write-Verbose "Removing PowerCtrl"
                Stop-Job -Job $BackgroundJob
                Remove-Job -Job $BackgroundJob
                [PowerCtrl]::AllowSleep()
            }

    } else {
        $TSParams = @{}
        switch ($PSBoundParameters.Keys) {
            'Minutes' {
                $TSParams.Add('Minutes', $Minutes)
                Write-Verbose "Adding $Minutes minutes of duration"
            }
            'Hours' {
                $TSParams.Add('Hours', $Hours)
                Write-Verbose "Adding $Hours hours of duration"
            }
            'Until' {
                Write-Verbose "Stopping time provided of: $($Until.ToShortTimeString())"
                $UntilDuration = ($Until - (Get-Date)).TotalMinutes
                If ($UntilDuration -lt 1) {
                    $UntilDuration = 1
                }
                Write-Verbose "Adding $UntilDuration minutes of duration"
                $TSParams.Add('Minutes', $UntilDuration)
            }
        }
        if (-not $TSParams.Count) {
            Write-Verbose "Defaulting to indefinite runtime"
            $Duration = $true
        } else {
            $Duration = (New-TimeSpan @TSParams).TotalMinutes
            Write-Verbose "Total duration is $Duration minutes"
        }

        $WShell = New-Object -ComObject WScript.Shell
        Write-Verbose $('Keeping computer awake by sending "{0}" every {1} seconds' -f $Key, $Interval)
        $SendKeyValue = ConvertKey-ToSendKeys -Key $Key
        while ($RunTime -le $Duration) {
            if ($Duration.GetType().Name -ne "Boolean") {
                Write-Verbose $('{0:n2} minutes remaining' -f ($Duration - $Runtime))
                $Runtime += $($Interval/60)
            }
            $WShell.SendKeys($SendKeyValue)
            Start-Sleep -seconds $Interval
        }
    }
}