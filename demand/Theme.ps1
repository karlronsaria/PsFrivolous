<#
.DESCRIPTION
Tags: theme wallpaper
#>
function Set-Wallpaper {
    Param(
        [Parameter(ValueFromPipeline = $true)]
        [String]
        $FilePath,

        [ValidateSet('Centered', 'Stretched', 'Fit', 'Fill')]
        $Style,

        [Boolean]
        $Tiled
    )

    Add-Type -TypeDefinition @"
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@

    Set-ItemProperty `
        -Path 'HKCU:/Control Panel/Desktop' `
        -Name wallpaper `
        -Value $FilePath

    $styleCode = switch ($Style) {
        'Centered' { 0 }
        'Stretched' { 2 }
        'Fit' { 4 }
        'Fill' { 10 }
    }

    if ('Style' -in $PsBoundParameters.Keys) {
        Set-ItemProperty `
            -Path 'HKCU:/Control Panel/Desktop' `
            -Name WallpaperStyle `
            -Value $styleCode
    }

    if ('Tiled' -in $PsBoundParameters.Keys) {
        Set-ItemProperty `
            -Path 'HKCU:/Control Panel/Desktop' `
            -Name TileWallpaper `
            -Value:$Tiled
    }

    return 1 -eq [Wallpaper]::SystemParametersInfo(0x14, 0, $FilePath, 0x1 -bor 0x2)
}

<#
.DESCRIPTION
Tags: theme shortcut icon overlay

Requires elevated permission

.LINK
Url: <https://www.elevenforum.com/t/remove-shortcut-arrow-icon-in-windows-11.3814/>
Retrieved: 2025-01-14
#>
function Set-ShortcutIconOverlay {
    #Requires -RunAs
    [CmdletBinding(DefaultParameterSetName = 'NoRestart')]
    Param(
        [Parameter(ParameterSetName = 'NoRestart')]
        [Parameter(ParameterSetName = 'Restart')]
        [Parameter(ValueFromPipeline = $true)]
        [String]
        $FilePath,

        [Parameter(ParameterSetName = 'Restart')]
        [Switch]
        $RestartExplorer,

        [Parameter(ParameterSetName = 'Restart')]
        [Switch]
        $ClearIconCache,

        [Switch]
        $Force
    )

    function Start-SystemRefresh {
        Param(
            [Switch]
            $ClearIconCache,

            [Switch]
            $Force
        )

        if ($RestartExplorer) {
            Stop-Process `
                -Name 'explorer' `
                -Force:$Force

            $iconCache = "$($env:LocalAppData)\IconCache.db"

            if ($ClearIconCache -and (Test-Path $iconCache)) {
                Remove-Item `
                    -Path $iconCache `
                    -Force:$Force
            }

            # link: wait for job with timeout
            # - url: <https://stackoverflow.com/questions/21176487/adding-a-timeout-to-batch-powershell>
            # - retrieved: 2025-01-14

            $script = {
                $process = Get-Process `
                    -Name 'explorer' `
                    -ErrorAction SilentlyContinue

                while ($null -ne $process) {
                    $process = Get-Process `
                        -Name 'explorer' `
                        -ErrorAction SilentlyContinue
                }
            }

            $job = Start-Job -ScriptBlock $script

            if (Wait-Job $job -Timeout 6) {
                Receive-Job $job

                Start-Process `
                    -Name 'explorer'
            }

            Remove-Job $job -Force
        }
    }

    $keyPath = 'HKLM:/Software/Microsoft/Windows/CurrentVersion/Explorer/Shell Icons'
    $keyExists = Test-Path $keyPath

    $key = Get-ItemProperty `
        -Path $keyPath `
        -ErrorAction SilentlyContinue

    if (-not $FilePath) {
        if (-not $keyExists) {
            return
        }

        Remove-ItemProperty `
            -Path $keyPath `
            -Name '29' `
            -ErrorAction SilentlyContinue `
            -Force:$Force

        if ($RestartExplorer) {
            Start-SystemRefresh `
                -ClearIconCache:$ClearIconCache `
                -Force:$Force
        }

        return
    }
    else {
        if (-not (Test-Path $FilePath)) {
            "The file path provided could not be found"
            return
        }

        # (karlr 2025-01-19): The file path to be added
        # needs to be a fully-qualified id
        $FilePath = $(Get-Item $FilePath).FullName
    }

    if (-not $keyExists) {
        New-Item `
            -Path $keyPath `
            -Force:$Force
    }

    New-ItemProperty `
        -Path $keyPath `
        -Name '29' `
        -Type String `
        -Value $FilePath `
        -Force:$Force

    if ($RestartExplorer) {
        Start-SystemRefresh `
            -ClearIconCache:$ClearIconCache `
            -Force:$Force
    }
}

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
        - retrieved: 2024-09-24
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

function Rename-DesktopItem {
    [CmdletBinding(DefaultParameterSetName = 'ByName')]
    Param(
        [Parameter(ParameterSetName = 'ByName')]
        [String]
        $ItemName,

        [Parameter(ParameterSetName = 'ByPath')]
        [String]
        $Path,

        [ValidateSet('RecycleBin', 'ThisPC')]
        [Parameter(ParameterSetName = 'Special')]
        [String]
        $Special,

        [String]
        $NewName
    )

    $shell = New-Object -ComObject Shell.Application
    $desktop = $shell.NameSpace(0)
    $items = $desktop.Items()

    $item = switch ($PsCmdlet.ParameterSetName) {
        'ByName' {
            $items | where { $_.Name -eq $ItemName }
        }

        'ByPath' {
            $items | where { $_.Path -eq $ItemName }
        }

        'Special' {
            $path = switch ($Special) {
                'RecycleBin' { "::{645FF040-5081-101B-9F08-00AA002F954E}" }
                'ThisPC' { "::{20D04FE0-3AEA-1069-A2D8-08002B30309D}" }
            }

            $items | where {
                $_.Path -eq $path
            }
        }
    }

    if ($null -eq $item) {
        return $false
    }

    $item.Name = $NewName
    return $true
}

