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
        $FontMap = "AnsiShadow",

        [Parameter(ParameterSetName = "ByPath")]
        [String]
        $FontPath = "$PsScriptRoot\..\res\fontmap\AnsiShadow.json",

        [Switch]
        $BoxAround
    )

    Begin {
        function Get-Message {
            Param(
                [PsCustomObject]
                $CharacterMap,

                [String]
                $InputString,

                [Switch]
                $BoxAround
            )

            $out = ""
            $index = 0
            $props = $CharacterMap.PsObject.Properties

            while ($index -lt $CharacterMap.CharacterLines) {
                $line = ""

                foreach ($c in $InputString.GetEnumerator()) {
                    $line += if ($c -match "(?-i)[A-Z]") {
                        if ($props.Name -contains "+$c") {
                            ($CharacterMap."+$c")[$index]
                        }
                        else {
                            ($CharacterMap.$c)[$index]
                        }
                    }
                    else {
                        ($CharacterMap.$c)[$index]
                    }
                }

                if ($BoxAround -and $out.Length -eq 0) {
                    $out += "┌" + ("─" * ($line.Length)) + "┐`n"
                }

                $out += if ($BoxAround) {
                    "|$line|`n"
                }
                else {
                    "$line`n"
                }

                $index = $index + 1
            }

            if ($BoxAround) {
                $out += "└" + ("─" * ($line.Length)) + "┘`n"
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
        foreach ($item in $Message) {
            Get-Message `
                -InputString $item `
                -CharacterMap $map `
                -BoxAround:$BoxAround

            "`r`n"
        }
    }
}

