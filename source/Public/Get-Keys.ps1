function Get-Keys {
    <#
    .SYNOPSIS
    Return an array of keys that be specified with the -Key parameter of Start-KeepAwake
    .DESCRIPTION
    Returns an array of possible keys that can be used with the -Key parameter of Start-KeepAwake
    .EXAMPLE
    PS> Get-Keys
    !
    "
    #
    $
    %
    &
    '
    (
    )
    *
    +
    ...

    truncated example output as this will print 131 possible keys.  This public function is mostly used in conjunction with Start-KeepAwake to support auto completion with the -Key parameter
    #>
    [Cmdletbinding()]
    param ()

    $Keys = [System.Collections.ArrayList]::new()
    33..126 | Foreach-Object {
        [Void]$Keys.Add([char]$_)
    }
    $SpecialKeys = @(
        "Shift",
        "Backspace",
        "Break",
        "CapsLock",
        "Delete",
        "Down",
        "End",
        "Enter",
        "Esc",
        "Help",
        "Home",
        "Insert",
        "Left",
        "Numlock",
        "PageDown",
        "PageUp",
        "PrintScreen",
        "Right",
        "ScrollLock",
        "Tab",
        "Up",
        "F1",
        "F2",
        "F3",
        "F4",
        "F5",
        "F6",
        "F7",
        "F8",
        "F9",
        "F10",
        "F11",
        "F12",
        "F13",
        "F14",
        "F15",
        "F16"
    )
    $SpecialKeys | Foreach-Object {
        [Void]$Keys.Add($_)
    }
    return $Keys
}