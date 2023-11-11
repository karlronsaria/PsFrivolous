Set-PsDebug -Strict

# . "$PsScriptRoot\Scripts\MyPsShortcut\MyPsShortcut.ps1"
# . "$PsScriptRoot\Scripts\PsMarkdown\PsMarkdown.ps1"

& "$PsScriptRoot/Scripts/PsFrivolous/Get-Scripts.ps1" | % { . $_ }

Set-Variable `
    -Scope 'Script' `
    -Name 'player' `
    -Value (New-Object System.Media.SoundPlayer)

$script:player.SoundLocation =
    dir "$PsScriptRoot/Scripts/PsFrivolous/res/intro/*.wav" | Get-Random

$script:player.Play()

Remove-Variable `
    -Scope 'Script' `
    -Name 'player'

function Write-HellfileGreeting {
    $script:msg = @{
        1 = @("HELL-o", "There!")
        2 = @("THATS NO", "GOOD")
        3 = @("Let me", "HELLp!")
    }

    Write-Host ""
    Write-Host `
        -ForegroundColor Red `
        -Object $(
            Get-BoxDrawnText `
                -Message $(
                    $myMessage = $script:msg[$($script:msg.Keys | Get-Random)]

                    switch ($PsVersionTable.PsVersion.Major) {
                        7 {
                            "$myMessage"
                        }
                        default {
                            $myMessage
                        }
                    }
                ) `
                -FontMap $(
                    switch ($PsVersionTable.PsVersion.Major) {
                        7 { "Edge" }
                        default { "Poison" }
                    }
                )
        )
}

Write-HellfileGreeting

Set-PromptAnnoying
Set-PsReadLineOption -EditMode Vi

# Write-TodoList
# Get-MySchedule


