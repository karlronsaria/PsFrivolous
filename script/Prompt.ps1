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

    $setting = cat "$PsScriptRoot/../res/setting.json" |
        ConvertFrom-Json

    $setting = $setting.Prompt

    if ([String]::IsNullOrWhiteSpace($ApplicationName)) {
        $ApplicationName = $setting.ApplicationName
    }

    if ([String]::IsNullOrWhiteSpace($ApplicationColor)) {
        $ApplicationColor = $setting.Color.Application
    }

    $time = Get-Date -Format $setting.TimeFormat

    if ((Compare-Object ($time) ($script:TimeCounter))) {
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
    Write-GitStatus (Get-GitStatus)

<#
    try {
        $global:GitStatus = Get-GitStatus
        Write-GitStatus $GitStatus
    }
    catch {
        $s = $global:GitPromptSettings

        if ($s) {
            $errorText = "PoshGitVcsPrompt error: $_"
            $sb = [System.Text.StringBuilder]::new()

            # When prompt is first (default), place the separator before the
            # status summary
            if (-not $s.DefaultPromptWriteStatusFirst) {
                $sb | Write-Prompt $s.PathStatusSeparator.Expand() > $null
            }

            $sb | Write-Prompt $s.BeforeStatus > $null
            $sb | Write-Prompt $errorText -Color $s.ErrorColor > $null

            if ($s.Debug) {
                if (-not $s.AnsiConsole) { Write-Host }

                Write-Verbose "PoshGitVcsPrompt error details: $($_ |
                    Format-List * -Force |
                    Out-String)" -Verbose
            }

            $sb | Write-Prompt $s.AfterStatus > $null

            if ($sb.Length -gt 0) {
                $sb.ToString()
            }
        }
    }
#>

    # Write-Output "`n> "
}

function global:Set-PromptFrivolous {
    Set-Item Function:\prompt -Value { Prompt-Frivolous }
}

