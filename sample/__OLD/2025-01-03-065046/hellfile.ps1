Set-PsDebug -Strict

& "$PsScriptRoot/Scripts/PsFrivolous/Get-Scripts.ps1" | % { . $_ }

# karlr 2023-11-29
$OutputEncoding =
[System.Console]::InputEncoding =
[System.Console]::OutputEncoding =
    [System.Text.Encoding]::UTF8

{
    $player = New-Object System.Media.SoundPlayer
    $player.SoundLocation =
        dir "$PsScriptRoot/Scripts/PsFrivolous/res/intro/*.wav" |
        Get-Random
    $player.Play()
}.Invoke()

{
    $msg = @{
        1 = @("HELL-o", "There!")
        2 = @("THAT'S NO", "GOOD")
        3 = @("Let me", "HELLp!")
        4 = @("You Disgust", "Me")
        5 = @("One must", "imagine You", "happy")
    }

    Write-Host ""
    Write-Host `
        -ForegroundColor Red `
        -Object $(
            Get-BoxDrawnText `
                -Message $(
                    $myMessage = $msg[$($msg.Keys | Get-Random)]

                    switch ($PsVersionTable.PsVersion.Major) {
                        7 { "$myMessage" }
                        default { $myMessage }
                    }
                ) `
                -FontMap $(
                    switch ($PsVersionTable.PsVersion.Major) {
                        # 7 { "Edge" }
                        7 { "Tmplr" }
                        default { "Poison" }
                    }
                )
        )
}.Invoke()

Set-PromptAnnoying
Set-PsReadLineOption -EditMode Vi

# Write-TodoList
# Get-MySchedule


