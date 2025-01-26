function Get-CurrentMoonPhase {
    Param(
        [Switch]
        $GetLink
    )

    # link
    # - retrieved: 2025_01_15
    $uri = "https://www.timeanddate.com/moon/phases/"

    if ($GetLink) {
        return $uri
    }

    $response = Invoke-WebRequest -Uri $uri

    if ($null -eq $response) {
        return
    }

    $content = $response.Content

    $capture = [regex]::Match(
        $content,
        "\<span id=cur-moon-percent\>(?<percent>(\d|\.)+)%\<\/span\>.*\<th\>Moon Phase Tonight: \<\/th\>\<td\>\<a[^\<\>]+\>(?<phasename>[^\<\>]+)\<\/a\>\<\/td\>"
    )

    $percent = [decimal]$capture.Groups['percent'].Value
    $phaseName = $capture.Groups['phasename'].Value

    [pscustomobject]@{
        Name = $phaseName
        Percent = $percent
        Emoji =
            switch ($phaseName) {
                'New Moon'        { '🌑', '🌚' | Get-Random }
                'Waxing Crescent' { '🌒' }
                'First Quarter'   { '🌓' }
                'Waxing Gibbous'  { '🌔' }
                'Full Moon'       { '🌕', '🌝' | Get-Random }
                'Waning Gibbous'  { '🌖' }
                'Third Quarter'   { '🌗' }
                'Last Quarter'    { '🌗' }
                'Waning Crescent' { '🌘' }
            }
    }
}

