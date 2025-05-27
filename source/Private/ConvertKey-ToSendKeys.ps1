function ConvertKey-ToSendKeys {
    <#
    .SYNOPSIS
    Converts a chosen key to appropriate format for use with the WScript SendKeys method
    .DESCRIPTION
    Most keys from the keyboard can simply be passed to SendKeys but some require special formatting. This function is meant to handle the special circumstances
    .PARAMETER Key
    the key to convert
    #>
    [CmdletBinding()]
    param (
        [String]$Key
    )


    $SpecialKeys = @{
        ')'             = '{)}'
        '('             = '{(}'
        '~'             = '{~}'
        '^'             = '{^}'
        '+'             = '{+}'
        '%'             = '{%}'
        Shift           = '+'
        Backspace       = '{Backspace}'
        Break           = '{Break}'
        CapsLock        = '{CapsLock}'
        Delete          = '{Delete}'
        Down            = '{Down}'
        End             = '{End}'
        Enter           = '{Enter}'
        Esc             = '{Esc}'
        Help            = '{Help}'
        Home            = '{Home}'
        Insert          = '{Insert}'
        Left            = '{Left}'
        Numlock         = '{Numlock}'
        PageDown        = '{PGDN}'
        PageUp          = '{PGUP}'
        PrintScreen     = '{PRTSC}'
        Right           = '{Right}'
        ScrollLock      = '{ScrollLock}'
        Tab             = '{Tab}'
        Up              = '{Up}'
        F1              = '{F1}'
        F2              = '{F2}'
        F3              = '{F3}'
        F4              = '{F4}'
        F5              = '{F5}'
        F6              = '{F6}'
        F7              = '{F7}'
        F8              = '{F8}'
        F9              = '{F9}'
        F10             = '{F10}'
        F11             = '{F11}'
        F12             = '{F12}'
        F13             = '{F13}'
        F14             = '{F14}'
        F15             = '{F15}'
        F16             = '{F16}'
    }

    $SpecialKeys[$Key]
}