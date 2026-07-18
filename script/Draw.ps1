<#
.LINK
Url: <https://www.kenmuse.com/blog/coloring-in-ansi/>
Retrieved: 2023-11-21
#>
function Write-Color {
    [CmdletBinding(DefaultParameterSetName = "ByPixel")]
    Param(
        [Parameter(ParameterSetName = "ByTriple")]
        [Parameter(ValueFromPipeline = $true)]
        [string[]]
        $InputObject,

        [Parameter(ParameterSetName = "ByPixel")]
        [System.Drawing.Color]
        $Pixel,

        [Parameter(ParameterSetName = "ByTriple")]
        [ValidateRange(0, 255)]
        [ValidateCount(3, 3)]
        [ArgumentCompleter({
            [OutputType([System.Management.Automation.CompletionResult])]
            Param($A, $B, $C)

            $CompletionResults =
                [System.Collections.Generic.List[System.Management.Automation.CompletionResult]]::new()

            1 .. 16 |
            ForEach-Object {
                16 * $_ - 1
            } |
            Where-Object {
                "$_" -like "$C*"
            } |
            ForEach-Object {
                $CompletionResults.Add($_)
            }

            return $CompletionResults
        })]
        [int[]]
        $Foreground,

        [Parameter(ParameterSetName = "ByTriple")]
        [ValidateRange(0, 255)]
        [ValidateCount(3, 3)]
        [ArgumentCompleter({
            [OutputType([System.Management.Automation.CompletionResult])]
            Param($A, $B, $C)

            $CompletionResults =
                [System.Collections.Generic.List[System.Management.Automation.CompletionResult]]::new()

            1 .. 16 |
            ForEach-Object {
                16 * $_ - 1
            } |
            Where-Object {
                "$_" -like "$C*"
            } |
            ForEach-Object {
                $CompletionResults.Add($_)
            }

            return $CompletionResults
        })]
        [int[]]
        $Background,

        [Int]
        $XScale = 1
    )

    Process {
        if ($PsCmdlet.ParameterSetName -eq "ByPixel") {
            $Background = $Pixel.R, $Pixel.G, $Pixel.B
            $out = "$([char]27)[48;2;$($Background -join ';')m $([char]27)[0m"
            $out * $XScale
        }
        else {
            foreach ($item in @($InputObject)) {
                $out = "$([char]27)[48;2;$($Background -join ';')m$([char]27)[38;2;$($Foreground -join ';')m$item$([char]27)[0m"
                $out * $XScale
            }
        }
    }
}

<#
.SYNOPSIS
Take any image and render it to the PowerShell command line, pixel by pixel.

.DESCRIPTION
Take any image and render it to the PowerShell command line, pixel by pixel.
Most command lines are 120 columns by default, so you want a picture that's smaller than that.

Author: naterice.com
Date: 2019-03-12

.LINK
Url: <https://naterice.com>
Retrieved: 2019-03-12

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
        [Parameter(
            ParameterSetName = "FromLocal",
            Position = 0
        )]
        [String]
        $Path,

        [Parameter(
            ParameterSetName = "FromOnline",
            Position = 0
        )]
        [String]
        $Url,

        [Int]
        $XScale = 1
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
        $line = New-Object System.Text.StringBuilder

        foreach ($x in $x_range) {
            $pixel = $bitmap.GetPixel($x, $y)
            
            $char = if ($pixel.A -eq 0) {
                ' ' * $XScale
            }
            else {
                Write-Color `
                    -Pixel $bitMap.GetPixel($x, $y) `
                    -XScale $XScale
            }

            [void] $line.Append($char)
        }

        $line.ToString()
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
        [Parameter(
            ValueFromPipeline = $true,
            Position = 0
        )]
        [Object[]]
        $InputObject,

        [Int]
        $Period = 64,

        [ValidateSet("ByCharacter", "ByPeriod", "ByColumn")]
        [String]
        $Mode = "ByColumn",

        [ValidateSet("Foreground", "Background")]
        [String]
        $ApplyTo = "Foreground",

        [Int]
        $Start = 0,

        [Switch]
        $NoNewline
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
                ($list |
                    Out-String -NoNewline:$NoNewline
                ) -Split "`n" |
                ForEach-Object {
                    Write-ColorWheel `
                        -InputObject $_ `
                        -Period $Period `
                        -Mode "ByPeriod" `
                        -Start $Start `
                        -ApplyTo $ApplyTo
                }
            }

            default {
                [System.Globalization.StringInfo]::
                GetTextElementEnumerator((
                    $list | Out-String -NoNewline:$NoNewline
                )) |
                ForEach-Object -Begin {
                    $i = $Start
                    $line = New-Object System.Text.StringBuilder
                } -Process {
                    $str = $_
                    $isSpace = [String]::IsNullOrWhiteSpace($str)

                    [void] $line.Append($(
                        if ($str -match "^\s*(`r|`n)$") {
                            ""
                        }
                        elseif ($isSpace) {
                            $str
                        }
                        else {
                            # Red, Green, and Blue must be equidistant
                            # on the color wheel, so each offset should
                            # be a multiple of (1/3)2π.
                            $r = Get-Signal -Arg $i
                            $g = Get-Signal -Arg $i -Offset (2.0/3)
                            $b = Get-Signal -Arg $i -Offset (4.0/3)

                            switch ($ApplyTo) {
                                'Foreground' {
                                    Write-Color `
                                        -InputObject $str `
                                        -Foreground $r, $g, $b
                                }

                                'Background' {
                                    Write-Color `
                                        -InputObject $str `
                                        -Background $r, $g, $b
                                }
                            }
                        }
                    ))

                    if ($Mode -ne "ByCharacter" -or -not $isSpace) {
                        $i = if ($i -eq ($Period - 1)) { 0 } else { $i + 1 }
                    }
                } -End {
                    $line.ToString()
                }
            }
        }
    }
}

