<#
.EXAMPLE
Get-BoxDrawnText -Message alex, 'you just', dropped, 'it in the fu' | Set-Clipboard

Use 'Set-Clipboard' when you want to copy the output to the clipboard.
System32\clip.exe does not accept box-drawing characters.
#>
function Get-BoxDrawnText {
    [CmdletBinding(DefaultParameterSetName = "ByName")]
    Param(
        [Parameter(ValueFromPipeline = $true)]
        [String[]]
        $Message,

        [Parameter(ParameterSetName = "ByName")]
        [ArgumentCompleter({
            return dir "$PsScriptRoot/../res/fontmap/*.json" |
                foreach {
                    $_.BaseName
                }
        })]
        [String]
        $FontMap = "Box",

        [Parameter(ParameterSetName = "ByPath")]
        [String]
        $FontPath = "$PsScriptRoot\..\res\fontmap\Box.json"
    )

    Begin {
        function Get-Message {
            Param(
                [PsCustomObject]
                $CharacterMap,

                [String]
                $InputString
            )

            $out = ""
            $index = 0

            while ($index -lt $CharacterMap.CharacterLines) {
                foreach ($c in $InputString.GetEnumerator()) {
                    $out += ($CharacterMap.$c)[$index]
                }

                $out += "`r`n"
                $index = $index + 1
            }

            return $out
        }

        $FontPath = switch ($PsCmdlet.ParameterSetName) {
            "ByName" {
                "$PsScriptRoot/../res/fontmap/$FontMap.json"
            }

            "ByPath" {
                $FontPath
            }
        }

        $map = cat $FontPath | ConvertFrom-Json
    }

    Process {
        foreach ($submessage in $Message) {
            Get-Message `
                -InputString $submessage `
                -CharacterMap $map

            Write-Output "`r`n"
        }
    }
}

