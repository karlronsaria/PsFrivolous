<#
.LINK
Url: <https://www.kenmuse.com/blog/coloring-in-ansi/>
Retrieved: 2023_11_21
#>
function Write-Color {
    [CmdletBinding(DefaultParameterSetName = "ByPixel")]
    Param(
        [String]
        $InputObject = " ",

        [Parameter(ParameterSetName = "ByPixel")]
        [System.Drawing.Color]
        $Pixel,

        [Parameter(ParameterSetName = "ByQuadruple")]
        [Int]
        $Alpha,

        [Parameter(ParameterSetName = "ByQuadruple")]
        [Int]
        $Red,

        [Parameter(ParameterSetName = "ByQuadruple")]
        [Int]
        $Green,

        [Parameter(ParameterSetName = "ByQuadruple")]
        [Int]
        $Blue,

        [Int]
        $XScale = 1,

        [ValidateSet("Foreground", "Background")]
        [String]
        $Mode = "Background",

        [Switch]
        $NoAlpha
    )

    if ($PsCmdlet.ParameterSetName -eq "ByPixel") {
        $Alpha = $Pixel.A
        $Red = $Pixel.R
        $Green = $Pixel.G
        $Blue = $Pixel.B
    }

    $ansi_escape = [char]27
    $alpha_str = if (-not $NoAlpha) { ";{3}" }

    $mode_num = switch ($Mode) {
        "Foreground" { 38 }
        "Background" { 48 }
    }

    $ansi_command = "$ansi_escape[$mode_num;2;{0};{1};{2}$($alpha_str)m" -f
        $Red,
        $Green,
        $Blue,
        $Alpha

    $ansi_terminate = "$ansi_escape[0m"
    $out = "$($ansi_command)$($InputObject)$($ansi_terminate)"
    Write-Host -NoNewline ($out * $XScale)
}

<#
.SYNOPSIS
Take any image and render it to the PowerShell command line, pixel by pixel.

.DESCRIPTION
Take any image and render it to the PowerShell command line, pixel by pixel.
Most command lines are 120 columns by default, so you want a picture that's smaller than that.

Author: naterice.com
Date: 2019_03_12

.LINK
Url: <https://naterice.com>
Retrieved: 2019_03_12

.EXAMPLE
Write-Bitmap .\picture.png

.EXAMPLE
Write-Bitmap -Path C:\full\path\picture.png

.EXAMPLE
Write-Bitmap -Url "https://f.thumbs.redditmedia.com/q9-214SeFCz5O0ik.png"

.EXAMPLE
Write-Bitmap -Url https://addons.thunderbird.net/user-media/addon_icons/347/347802-64.png?modified=1322749240
#>

function Write-Bitmap {
    [CmdletBinding(DefaultParameterSetName = "FromLocal")]
    Param(
        [Parameter(ParameterSetName = "FromLocal")]
        [String]
        $Path,

        [Parameter(ParameterSetName = "FromOnline")]
        [String]
        $Url,

        [Int]
        $XScale = 1,

        [Switch]
        $NoAlpha
    )

    [void][System.Reflection.Assembly]::
    LoadWithPartialName('System.Drawing')

    $bitMap = switch ($PsCmdlet.ParameterSetName) {
        "FromLocal" {
            if ([String]::IsNullOrWhiteSpace($Path)) {
                return
            }

            [System.Drawing.Bitmap]::FromFile((Get-Item $Path).FullName)
        }

        "FromOnline" {
            if ([String]::IsNullOrWhiteSpace($Url)) {
                return
            }

            [System.Drawing.Bitmap]::FromStream(
                $(Invoke-WebRequest $Url).RawContentStream
            )
        }
    }

    $x_range = (0 .. ($bitMap.Width - 1))

    if ($XScale -lt 0) {
        $XScale = -$XScale
        $x_range = (($bitMap.Width - 1) .. 0)
    }

    foreach ($y in (0 .. ($bitMap.Height - 1))) {
        foreach ($x in $x_range) {
            Write-Color `
                -Pixel $bitMap.GetPixel($x, $y) `
                -XScale $XScale `
                -NoAlpha:$NoAlpha
        }

        Write-Host ""
    }

    $bitMap.Dispose()
}

<#
.PARAMETER CharDependent
Specifies that the color should only rotate on non-whitespace characters,
giving a much more chaotic appearance.
#>
function Write-ColorWheel {
    Param(
        [Parameter(ValueFromPipeline = $true)]
        [Object[]]
        $InputObject,

        [Int]
        $Period = 64,

        [ValidateSet("Foreground", "Background")]
        [String]
        $ApplyTo = "Foreground",

        [ValidateSet("ByCharacter", "ByPeriod", "ByColumn")]
        [String]
        $Mode = "ByColumn"
    )

    Begin {
        Add-Type -AssemblyName System.Drawing

        function Get-Signal {
            Param(
                [Double] $Argument,
                [Double] $Offset = 0,
                [Double] $Amplitude = 255
            )

            # S(x) = (1/2)A (1 + cos( x(2π/P) + k(π) ))

            return ($Amplitude/2) * (1 + [Math]::Cos(
                [Math]::PI * (2 * $Argument / $Period + $Offset)
            ))
        }

        $list = @()
    }

    Process {
        foreach ($item in $InputObject) {
            $list += @($item)
        }
    }

    End {
        switch ($Mode) {
            "ByColumn" {
                ($list | Out-String) -Split "`n" | foreach {
                    Write-ColorWheel `
                        -InputObject $InputObject `
                        -Period $Period `
                        -ApplyTo $ApplyTo `
                        -Mode "ByPeriod"
                }
            }

            default {
                $($list | Out-String).GetEnumerator() |
                foreach -Begin {
                    $i = 0
                } -Process {
                    $isSpace = [Char]::IsWhiteSpace($_)

                    if ($isSpace) {
                        Write-Host $_ -NoNewline
                    }
                    else {
                        # Red, Green, and Blue must be equidistant on the
                        # color wheel, so each offset should be a multiple
                        # of (1/3)2π.
                        $r = Get-Signal -Arg $i
                        $g = Get-Signal -Arg $i -Offset (2.0/3)
                        $b = Get-Signal -Arg $i -Offset (4.0/3)

                        Write-Color `
                            -InputObject $_ `
                            -Red $r `
                            -Green $g `
                            -Blue $b `
                            -Mode $ApplyTo `
                            -NoAlpha
                    }

                    if ($Mode -ne "ByCharacter" -or -not $isSpace) {
                        $i = if ($i -eq ($Period - 1)) { 0 } else { $i + 1 }
                    }
                }
            }
        }
    }
}

