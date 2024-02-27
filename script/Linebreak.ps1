function Get-LinotypeBreak {
    Param(
        [Parameter(ValueFromPipeline = $true)]
        [String[]]
        $InputObject = @(),

        [Int]
        $Length = 85,

        [Int]
        $Frequency = 20
    )

    Begin {
        function Get-LineBreak {
            Param(
                [String]
                $InputObject = "",

                [Int]
                $Length,

                [Int]
                $Frequency
            )

            $line = ""
            $word = ""

            foreach ($c in $InputObject.GetEnumerator()) {
                if ([Char]::IsWhiteSpace($c)) {
                    if ($line.Length + $word.Length + 1 -gt $Length) {
                        $line
                        $line = $word
                    }
                    else {
                        $chance = (Get-Random) % $Frequency

                        if (-not [String]::IsNullOrEmpty($line) -and $word.Length -gt 2 -and $line.Length + $word.Length + 17 -lt $Length -and $chance -eq 0) {
                            $i =
                                if ($word.Length - 3 -eq 0) {
                                    1
                                }
                                else {
                                    Get-Random -Min 1 -Max ($word.Length - 2)
                                }

                            $j =
                                if ($word.Length - 1 -eq $i + 1) {
                                    $i + 1
                                }
                                else {
                                    Get-Random -Min ($i + 1) -Max ($word.Length - 1)
                                }

                            $a = $word.Substring(0, $i)  # Get-Slice -In $word -S 0 -E ($i - 1)
                            $b = $word.Substring($i + 1, $j - $i - 1)  # Get-Slice -In $word -S ($i + 1) -E ($j - 1)
                            $c = $word.Substring($j + 1, $word.Length - $j - 1)  # Get-Slice -In $word -S ($j + 1) -E ($word.Length - 1)

                            $mistake = "$a$($word[$j])$b$($word[$i])$c"
                            "$line $mistake etaoin shrdlu $('m' * 40)".Substring(0, 40)
                        }

                        $line += if ([String]::IsNullOrEmpty($line)) {
                            $word
                        }
                        else {
                            " $word"
                        }
                    }

                    $word = ""
                }
                else {
                    $word += $c
                }
            }

            if ($line.Length + $word.Length + 1 -gt $Length) {
                $line
                $word
            }
            else {
                "$line $word"
            }
        }

        $lines = @()
        $list = @()
    }

    Process {
        $list += @($InputObject)
    }

    End {
        foreach ($line in @($list)) {
            if ([String]::IsNullOrWhiteSpace($line)) {
                Get-LineBreak `
                    -InputObject ($lines -join " ") `
                    -Length $Length

                $line
                $lines = @()
            }
            else {
                $lines += @($line)
            }
        }

        Get-LineBreak `
            -InputObject ($lines -join " ") `
            -Length $Length
    }
}

