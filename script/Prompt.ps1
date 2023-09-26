$script:TimeCounter = ""

function global:Prompt-Frivolous {
    Param(
        [Alias("AppName", "Name")]
        [String]
        $ApplicationName,

        [Alias("AppColor", "Color")]
        [System.ConsoleColor]
        $ApplicationColor
    )

    $setting = cat "$PsScriptRoot/../res/setting.json" `
        | ConvertFrom-Json

    $setting = $setting.Prompt

    if ([String]::IsNullOrWhiteSpace($ApplicationName) {
        $ApplicationName = $setting.ApplicationName
    }

    if ([String]::IsNullOrWhiteSpace($ApplicationColor) {
        $ApplicationColor = $setting.Color.Application
    }

    $time = Get-Date -Format $setting.TimeFormat

    if ((diff ($time) ($script:TimeCounter))) {
        Write-Host (Get-Date -Format $setting.DateTimeFormat) `
            -ForegroundColor $setting.Color.Date
        $script:TimeCounter = $time
    }

    Write-Host "$ApplicationName " `
        -ForegroundColor ($ApplicationColor.ToString()) `
        -NoNewline
    Write-Host $env:USERNAME `
        -ForegroundColor $setting.Color.User `
        -NoNewline
    Write-Host "@" `
        -NoNewline
    Write-Host "$env:USERDOMAIN~ " `
        -ForegroundColor $setting.Color.Domain `
        -NoNewline
    Write-Host (Get-Location).Path `
        -NoNewline
    Write-Output "> "
}

function global:Set-PromptFrivolous {
    Set-Item Function:\prompt -Value { Prompt-Frivolous }
}

