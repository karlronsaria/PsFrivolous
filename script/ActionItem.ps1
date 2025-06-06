Set-StrictMode -Version 7.0


filter NotEmpty {
    [OutputType([Boolean])]
    [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipeline = $true)]
        [String]
        $InputString
    )
    
    return ![String]::IsNullOrEmpty($InputString)
}


filter NotBlank {
    [OutputType([Boolean])]
    [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipeline = $true)]
        [String]
        $InputString
    )
    
    return ![String]::IsNullOrWhiteSpace($InputString)
}


filter TabToSpace {
    [OutputType([String])]
    [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipeline = $true)]
        [String]
        $InputString,
        
        [Alias("Size")]
        [Int]
        $TabSize = 4
    )
    
    Process {
        $output = ""
        $slack = $TabSize
        
        foreach ($n in $InputString.GetEnumerator()) {
            if ("$n" -eq "`t") {
                $output += (" " * $slack)
                $slack = $TabSize
            }
            else {
                $output += $n
                
                $slack = if ($slack -eq 1 -or "$n" -eq "`r" -or "$n" -eq "'`n'") {
                    $TabSize
                }
                else {
                    $slack - 1
                }
            }
        }
        
        return $output
    }
}


function Get-ActionItemObject {
    [OutputType([PsCustomObject])]
    [CmdletBinding()]
    Param(
        [Alias("Path")]
        [Parameter(ValueFromPipeline = $true)]
        $FilePath,

        [Int]
        $MaxDescriptionLines = 4
    )

    Begin {
        function Get-ActionItemDepth {
            [OutputType([Int])]
            Param(
                [String]
                $InputObject
            )

            return [Regex]::Match($InputObject, "^\s+").Length
        }

        function Get-NextNonEmptyLineIndex {
            [OutputType([Int])]
            Param(
                [String[]]
                $Lines,

                [Int]
                $Index
            )

            while ($Index -lt $Lines.Count `
                -and [String]::IsNullOrWhiteSpace($Lines[$Index]))
            {
                $Index = $Index + 1
            }

            return $Index
        }

        function Get-NextLine {
            Param(
                [String[]]
                $Lines,

                [Int]
                $Index
            )

            if ($Index -ge $Lines.Count) {
                return $null
            }

            return $Lines[$Index] | TabToSpace
        }

        $pat = (cat "$PsScriptRoot/../res/setting.json" `
            | ConvertFrom-Json).ActionList.MarkdownBranchPattern

        $pattern = "$pat\[ \].*$"
        $generalPattern = "$pat\[[^\[\]]\].*$"
        $count = 0
    }

    Process {
        foreach ($item in $FilePath) {
            $count = $count + 1
            $lines = Get-Content $item
            $depth = 0
            $heading = ""
            $i = 0

            if ($null -eq $lines) {
                continue
            }

            while ($i -lt @($lines).Count) {
                # Get heading
                if ($lines[$i] -notmatch $pattern) {
                    if ([String]::IsNullOrWhiteSpace($lines[$i])) {
                        $i = $i + 1
                        continue
                    }

                    $line = $lines[$i] | TabToSpace
                    $nextDepth = Get-ActionItemDepth $line

                    if ($nextDepth -gt $depth) {
                        $line = $line.Trim()
                        $heading = "$heading`: $line"
                    } else {
                        $heading = $line.Trim()
                    }

                    $depth = $nextDepth
                    $i = $i + 1
                    continue
                }

                # Get action item
                $line = $lines[$i] | TabToSpace
                $action = $line
                $description = @()
                $nextDepth = Get-ActionItemDepth $line

                # If the heading text doesn't belong to a parent node,
                # don't use it as a heading
                if ($nextDepth -lt $depth) {
                    $heading = ""
                }

                $depth = $nextDepth
                $i = Get-NextNonEmptyLineIndex $lines ($i + 1)
                $line = Get-NextLine $lines $i
                $descLineCount = 0

                while ($line -ne $null `
                    -and $line -notmatch $generalPattern `
                    -and $descLineCount -lt $MaxDescriptionLines `
                    -and (Get-ActionItemDepth $line) -gt $depth)
                {
                    $description += $line
                    $descLineCount++
                    $i = Get-NextNonEmptyLineIndex $lines ($i + 1)
                    $line = Get-NextLine $lines $i
                }

                $object = [PsCustomObject]@{
                    Heading = $heading
                    Action = $action
                    Description = $description
                    Depth = $depth
                    Location = $FilePath
                }

                Write-Output $object
            }
        }
    }
}


function Get-ActionItem {
    [OutputType([String])]
    [CmdletBinding()]
    Param(
        [Alias("Path")]
        [Parameter(ValueFromPipeline = $true)]
        [String[]]
        $FilePath,

        # Starts at 1
        [Int]
        $At = 0 
    )

    Begin {
        $pattern = (cat "$PsScriptRoot/../res/setting.json" `
            | ConvertFrom-Json).ActionList.MarkdownBranchPattern

        $pattern = "$pattern\[ \].*$"
        $count = 0
    }

    Process {
        foreach ($item in $FilePath) {
            $count = $count + 1

            if ($At -in @(0, $count)) {
                Get-Content $item | foreach { $_ } | where { $_ -match $pattern }
            }
        }
    }
}


function Write-HeaderItemObjectToHost {
    [OutputType([Void])]
    [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipeline = $true)]
        [PsCustomObject[]]
        $InputObject,

        [Int]
        $MaxLength = 68,

        [Int]
        $First = 5,

        [String]
        $TextColor = [System.Console]::ForegroundColor,

        [String]
        $NumberColor,

        [Int]
        $Indent = 0
    )

    Begin {
        function Get-TruncatedString {
            Param(
                [String]
                $InputObject,

                [Int]
                $MaxLength,

                [String]
                $Ellipsis
            )

            if ($InputObject.Length -gt $MaxLength) {
                return $InputObject.Substring(0, ($MaxLength - $Ellipsis.Length)) + $Ellipsis
            }

            return $InputObject
        }

        $count = 0
        $maxHeadingLen = 20
        $ellipsis = "..."

        if (-not $NumberColor) {
            $NumberColor = $TextColor
        }

        $pattern = (cat "$PsScriptRoot/../res/setting.json" `
            | ConvertFrom-Json).ActionList.MarkdownBranchPattern
    }

    Process {
        foreach ($item in $InputObject) {
            $count = $count + 1

            if ($count -le $First) {
                $line = ($item.Action | TabToSpace).Substring($item.Depth)
                $space = " " * $Indent
                $number = "$space$count"
                $heading = Get-TruncatedString $item.Heading $maxHeadingLen $ellipsis

                if (-not [String]::IsNullOrEmpty($heading)) {
                    $line = $line -Replace "(?<=$pattern\[[^\[\]]\])\s", " $heading`: "
                }

                $len = $line.Length

                if ($len -gt $MaxLength) {
                    $line = Get-TruncatedString $line $MaxLength $ellipsis
                }

                Write-Host $number -ForegroundColor $NumberColor -NoNewLine
                Write-Host " $line" -ForegroundColor $TextColor

                $space = " " * $number.Length

                foreach ($line in $item.Description) {
                    $line = ($line | TabToSpace).Substring($item.Depth)
                    Write-Host "$space $line" -ForegroundColor $NumberColor
                }
            }
        }
    }
}


function Write-HeaderItemToHost {
    [OutputType([Void])]
    [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipeline = $true)]
        [Object[]]
        $InputObject,

        [Int]
        $MaxLength = 68,

        [Int]
        $First = 5,

        [String]
        $TextColor = [System.Console]::ForegroundColor,

        [String]
        $NumberColor,

        [Int]
        $Indent = 0
    )

    Begin {
        $count = 0

        if (-not $NumberColor) {
            $NumberColor = $TextColor
        }
    }

    Process {
        foreach ($item in $InputObject) {
            $count = $count + 1

            if ($count -le $First) {
                $line = $item | TabToSpace
                $len = $line.Length

                if ($len -gt $MaxLength) {
                    $line = $line.Substring(0, $MaxLength)
                }

                $space = " " * $Indent
                Write-Host "$space$count" -ForegroundColor $NumberColor -NoNewLine
                Write-Host " $line" -ForegroundColor $TextColor
            }
        }
    }
}
