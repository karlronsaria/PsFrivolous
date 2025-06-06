function Start-PsalmOfTheDay {
    [CmdletBinding(DefaultParameterSetName = "OpenInBrowser")]
    Param(
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [Int]
        $DayOfYear,

        [Parameter(ParameterSetName = "OpenInBrowser")]
        [ValidateSet("msedge", "chrome", "firefox", "iexplore")]
        [String]
        $OpenWith,

        [Parameter(ParameterSetName = "DoNotOpenInBrowser")]
        [Switch]
        $DoNotGo,

        [Parameter(ParameterSetName = "OpenInBrowser")]
        [Switch]
        $GetUrl
    )

    $web_site = "https://www.biblegateway.com"
    $psa_number = 119
    $stanzas = 22

    function Test-IsInPsa119 {
        Param([Int] $InputObject)

        return $InputObject -ge $psa_number `
            -and $InputObject -le ($psa_number + $stanzas - 1)
    }

    function Get-PsalmNumber {
        Param([Int] $InputObject)

        Write-Output $(if (Test-IsInPsa119 $InputObject) {
            $psa_number
        }
        elseif ($InputObject -gt $psa_number) {
            $InputObject - $stanzas + 1
        }
        else {
            $InputObject
        })
    }

    function Get-Psa119StanzaVerse {
        Param([Int] $InputObject)

        Write-Output $(if (Test-IsInPsa119 $InputObject) {
            ($InputObject - $psa_number) * 8 + 1
        }
        else {
            0
        })
    }

    if (-not $DayOfYear) {
        $DayOfYear = (Get-Date).DayOfYear
    }

    $psalm_number = ($DayOfYear - 1) % (150 + $stanzas - 1) + 1
    $verse_number = Get-Psa119StanzaVerse $psalm_number
    $psalm_number = Get-PsalmNumber $psalm_number

    $url = "$web_site/passage/?search=psa+$(if ($verse_number) {
        "119.$verse_number-$($verse_number + 7)"
    } else {
        "$psalm_number"
    })&version=ESV"

    switch ($PsCmdlet.ParameterSetName) {
        "OpenInBrowser" {
            if ($OpenWith) {
                [System.Diagnostics.Process]::Start($OpenWith, $url)
            }
            else {
                Start-Process $url
            }

            if ($GetUrl) {
                Write-Output $url
            }
        }

        "DoNotOpenInBrowser" {
            Write-Output $url
        }
    }
}

