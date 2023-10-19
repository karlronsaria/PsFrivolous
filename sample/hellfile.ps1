Set-PsDebug -Strict

# . "$PsScriptRoot\Scripts\MyPsShortcut\MyPsShortcut.ps1"
# . "$PsScriptRoot\Scripts\PsMarkdown\PsMarkdown.ps1"

& "$PsScriptRoot/Scripts/PsFrivolous/Get-Scripts.ps1" | % { . $_ }

Set-Variable `
    -Scope 'Script' `
    -Name 'player' `
    -Value (New-Object System.Media.SoundPlayer)

$script:player.SoundLocation =
    dir "$PsScriptRoot/Scripts/PsFrivolous/res/burning-intro.wav"
$script:player.Play()

Remove-Variable `
    -Scope 'Script' `
    -Name 'player'

Set-PromptAnnoying
Set-PsReadLineOption -EditMode Vi

# Write-TodoList
# Get-MySchedule


