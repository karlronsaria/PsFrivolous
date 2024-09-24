<#
.DESCRIPTION
Tags: theme cursor mouse pointer
#>
function Set-MousePointerImage {
    [CmdletBinding()]
    Param(
        $Theme
    )

    function Start-CursorRefresh {
        [Alias('Set-CursorImage')]
        <#
        .LINK
        - url
          - <https://superuser.com/questions/1769195/how-to-change-mouse-cursor-using-powershell-script-on-windows-11-without-restart>
          - <https://superuser.com/users/8672/harrymc>
          - <https://devblogs.microsoft.com/scripting/use-powershell-to-change-the-mouse-pointer-scheme/>
        - retrieved: 2024_09_24
        #>
        $cSharpSig =
@'
[DllImport("user32.dll", EntryPoint = "SystemParametersInfo")]
public static extern bool SystemParametersInfo(
    uint uiAction,
    uint uiParam,
    uint pvParam,
    uint fWinIni);
'@

        $cursorRefresh = Add-Type `
            -MemberDefinition $cSharpSig `
            -Name WinAPICall `
            -Namespace SystemParamInfo `
            –PassThru

        $cursorRefresh::SystemParametersInfo(0x0057, 0, $null, 0)
    }

    if ($null -eq $Theme) {
        $Theme = [PsCustomObject]@{}
    }

    $defaultTheme = dir "$PsScriptRoot/../res/theme.setting.json" |
        Get-Content |
        ConvertFrom-Json |
        foreach { $_.MousePointerThemes } |
        where { $_.Name -eq 'SystemDefault' } |
        foreach { $_.Theme }

    $themeKeys = switch ($Theme) {
        { $_ -is [PsCustomObject] } {
            $Theme.PsObject.Properties.Name
        }

        { $_ -is [Hashtable] } {
            $Theme.Keys
        }
    }

    # Path to the registry key
    $regPath = "HKCU:/Control Panel/Cursors"
    $entries = @()

    # Apply the cursor scheme to the registry
    foreach ($key in $defaultTheme.PsObject.Properties.Name) {
        $value = if ($themeKeys -contains $key) {
            switch ($Theme) {
                { $_ -is [PsCustomObject] } {
                    $Theme.$key
                }

                { $_ -is [Hashtable] } {
                    $Theme[$key]
                }
            }
        }
        else {
            $defaultTheme.$key
        }

        $entries += @([PsCustomObject]@{
            Key = $key
            Value = $value
        })

        Set-ItemProperty -Path $regPath -Name $key -Value $value
    }

    # Notify the system of the change
    RUNDLL32.EXE USER32.DLL,UpdatePerUserSystemParameters ,1 ,True

    return $([PsCustomObject]@{
        # Refresh the system
        Success = Start-CursorRefresh
        Path = $regPath
        Entries = $entries
    })
}

function Set-MousePointerTheme {
    Param(
        [ArgumentCompleter({
            Param($A, $B, $C)

            $names = dir "$PsScriptRoot/../res/theme.setting.json" |
                Get-Content |
                ConvertFrom-Json |
                foreach { $_.MousePointerThemes.Name }

            return $($names | where { $_ -like "$C*" })
        })]
        [String]
        $Name
    )

    if (-not $Name) {
        $Name = 'SystemDefault'
    }

    $theme = dir "$PsScriptRoot/../res/theme.setting.json" |
        Get-Content |
        ConvertFrom-Json |
        foreach { $_.MousePointerThemes } |
        where { $_.Name -eq $name } |
        foreach { $_.Theme }

    return Set-MousePointerImage `
        -Theme $theme `
        -Verbose:$Verbose
}

