function Get-CurrentMoonPhase {
    # link
    # - retrieved: 2025_01_15
    $uri = "https://www.timeanddate.com/moon/phases/"

    $response = invoke-webrequest -Uri $uri

    if ($null -eq $response) {
        return
    }

    $response.
        Content.
        Split("`n") |
    foreach {
        [regex]::Match(
            $_,
            "(?<=\<th\>Moon Phase Tonight: \<\/th\>\<td\>\<a[^\<\>]+\>)[^\<\>]+(?=\<\/a\>\<\/td\>)"
        )
    } |
    where {
        $_.Success
    } |
    foreach {
        [pscustomobject]@{
            Name = $_.Value
            Emoji =
                switch ($_.Value) {
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
}

