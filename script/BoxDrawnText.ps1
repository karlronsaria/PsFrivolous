<#
.EXAMPLE
Get-BoxDrawnText -Message alex, 'you just', dropped, 'it in the fu' | Set-Clipboard

Use 'Set-Clipboard' when you want to copy the output to the clipboard.
System32\clip.exe does not accept box-drawing characters.
#>
function Get-BoxDrawnText {
    [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipeline = $true)]
        [String[]]
        $Message,

        [String]
        $CharacterMapPath = "$PsScriptRoot\..\res\boxDrawnText.json"
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

        $map = cat $CharacterMapPath | ConvertFrom-Json
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

