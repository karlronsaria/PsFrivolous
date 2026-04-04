function choco {
    & 'choco.exe' $args

    if ($args -contains 'upgrade') {
        $sound = @(es -r "upgrade.*complete.*\.wav") |
            Get-Random

        (New-Object System.Media.SoundPlayer $sound).Play()
    }
}

function Start-Drive {
    if ((Get-Random -Min 1 -Max 100) -le 25) {
        $sound = "$PsScriptRoot/../res/vinny/*.wav" |
            Get-ChildItem |
            Get-Random

        (New-Object System.Media.SoundPlayer $sound).PlaySync()
    }
}
