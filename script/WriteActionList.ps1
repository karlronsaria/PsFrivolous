#Requires -Module Posh-Git

Import-Module Posh-Git

function script:Write-ActionListHeader {
    Param(
        [String]
        $KeyWord
    )

    $setting = cat "$PsScriptRoot/../res/setting.json" `
        | ConvertFrom-Json

    $setting = $setting.ActionList
    $space = " " * $setting.Indent
    $heading = "$KeyWord ($(Get-Date -Format $setting.DateFormat))"
    $divider = "-" * $heading.Length

    Write-Host "$space$heading" -ForegroundColor $setting.TextColor
    Write-Host "$space$divider" -ForegroundColor $setting.TextColor
}

function Write-ActionList {
    Param(
        [String]
        $FilePattern,

        [Switch]
        $Descending,

        [String]
        $SortBy = "Name",

        [Int]
        $First = 5
    )

    $setting = cat "$PsScriptRoot/../res/setting.json" `
        | ConvertFrom-Json

    $setting = $setting.ActionList

    if ([String]::IsNullOrWhiteSpace($FilePattern)) {
        $FilePattern = "*.md", "*.txt"
    }

    dir $FilePattern `
            -File `
            -Recurse `
        | foreach { `
            $_.FullName `
        } `
        | Sort-Object `
            -Property $SortBy `
            -Descending:$Descending `
        | Get-ActionItemObject `
        | Write-HeaderItemObjectToHost `
            -Indent $setting.Indent `
            -TextColor $setting.TextColor `
            -NumberColor $setting.NumberColor `
            -First $First
}

function Write-EventList {
    [CmdletBinding()]
    Param(
        [String]
        $FilePattern,

        [Int]
        $First = 5
    )

    $setting = cat "$PsScriptRoot/../res/setting.json" `
        | ConvertFrom-Json

    $setting = $setting.ActionList

    if ([String]::IsNullOrWhiteSpace($FilePattern)) {
        $FilePattern = $setting.FilePattern
    }

    $KeyWord = "REMINDERS"

    Write-Host ""
    Write-ActionListHeader `
        -KeyWord $KeyWord
    Write-ActionList `
        -FilePattern $FilePattern `
        -First $First
    Write-Host ""
}

function Write-TodoList {
    [CmdletBinding(DefaultParameterSetName = "Do")]
    Param(
        [String]
        $FilePattern,

        [Int]
        $First = 5
    )

    $setting = cat "$PsScriptRoot/../res/setting.json" `
        | ConvertFrom-Json

    $setting = $setting.ActionList

    if ([String]::IsNullOrWhiteSpace($FilePattern)) {
        $FilePattern = $setting.FilePattern
    }

    $KeyWord = "TODO"

    Write-Host ""
    Write-ActionListHeader `
        -KeyWord $KeyWord
    Write-ActionList `
        -FilePattern $FilePattern `
        -Descending `
        -First $First
    Write-Host ""
}

function Write-Schedule {
    [CmdletBinding()]
    Param(
        [DateTime]
        $Date = (Get-Date),

        [Parameter()]
        [String]
        $FilePattern
    )

    function Get-Segments {
        Param(
            [String]
            $Line,

            [ValidateSet("   ", ".  ")]
            [String]
            $Replacement
        )

        $clockLen = 8
        $dayLen = 12
        $numDays = 8

        $obj = [PsCustomObject]@{
            Clock = ""
            DaySegments = @()
        }

        $paddingLen = $clockLen + ($numDays * $dayLen) - $Line.Length

        if ($paddingLen -lt 0) {
            $paddingLen = 0
        }

        $Line = $Line + (" " * $paddingLen)

        $capture = [Regex]::Match( `
            $Line, `
            "^(.{$clockLen})$("(.{$dayLen})" * $numDays)" `
        )

        $obj.Clock = $capture.Groups[1].Value

        $capture.Groups[2 .. ($capture.Groups.Count - 1)] | foreach {
            $obj.DaySegments += @(
                if ([String]::IsNullOrWhiteSpace($_.Value)) {
                    $Replacement * 4
                } else {
                    $_.Value
                }
            )
        }

        return $obj
    }

    function Write-Line {
        Param(
            [String]
            $Line,

            [System.ConsoleColor]
            $FirstColor,

            [System.ConsoleColor]
            $SecndColor,

            [DateTime]
            $Date,

            [ValidateSet("   ", ".  ")]
            [String]
            $Replacement,

            [Switch]
            $DifferentPointSegment
        )

        $days = @(
            "Every", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"
        )

        $obj = Get-Segments -Line $Line -Replacement $Replacement
        $day = Get-Date -Date $Date -Format "ddd"
        $index = $days.IndexOf($day)

        Write-Host $obj.Clock `
            -ForegroundColor $FirstColor `
            -NoNewLine

        $count = 0

        while ($count -lt $index) {
            Write-Host $obj.DaySegments[$count] `
                -ForegroundColor $FirstColor `
                -NoNewLine

            $count = $count + 1
        }

        $pointSegment = $obj.DaySegments[$count]

        if ($DifferentPointSegment) {
            $pointSegment = $pointSegment -Replace "^\. ", "> "
        }

        Write-Host $pointSegment `
            -ForegroundColor $SecndColor `
            -NoNewLine

        $count = $count + 1

        while ($count -lt $days.Count) {
            Write-Host $obj.DaySegments[$count] `
                -ForegroundColor $FirstColor `
                -NoNewLine

            $count = $count + 1
        }

        Write-Host ""
    }

    $setting = cat "$PsScriptRoot/../res/setting.json" `
        | ConvertFrom-Json

    $setting = $setting.ActionList

    if ([String]::IsNullOrWhiteSpace($FilePattern)) {
        $FilePattern = $setting.FilePattern
    }

    $dir = dir $FilePattern -Recurse

    if (-not $dir) {
        return
    }

    $crossColor = [System.ConsoleColor]::Yellow
    $pointColor = [System.ConsoleColor]::Magenta
    $cat = cat @($dir)[-1]
    $time = 0

    foreach ($item in $cat) {
        $capture = [Regex]::Match($item, "^\s*\d+")

        if ($capture.Success) {
            $time = [Int]::Parse($capture.Value)
        }

        $myArgs = @{
            Line = $item
            FirstColor = [System.Console]::ForegroundColor
            SecndColor = $crossColor
            Date = $Date
            Replacement = "   "
            DifferentPointSegment = $false
        }

        $lineMatchHour = $time -eq [Int]::Parse( `
            (Get-Date -Date $Date -Format "HH") `
        )

        $passedHalfHour = 30 -le [Int]::Parse( `
            (Get-Date -Date $Date -Format "mm") `
        )

        if ( `
            $lineMatchHour -and `
            (($passedHalfHour -and -not $capture.Success) -or `
             (-not $passedHalfHour -and $capture.Success)) `
        ) {
            $myArgs.FirstColor = $crossColor
            $myArgs.SecndColor = $pointColor
            $myArgs.Replacement = ".  "
            $myArgs.DifferentPointSegment = $true
        }

        Write-Line @myArgs
    }
}
