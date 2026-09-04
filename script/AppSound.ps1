function choco {
    & 'choco.exe' $args

    if ($args -contains 'upgrade') {
        $sound = @(es -r "upgrade.*complete.*\.wav") |
            Get-Random

        (New-Object System.Media.SoundPlayer $sound).Play()
    }
}

function Start-Drive {
    "Let's go for a drive!"
    
    while ($true) {
        if ((Get-Random -Min 1 -Max 100) -le 25) {
            $sound = "$PsScriptRoot/../res/vinny/*.wav" |
                Get-ChildItem |
                Get-Random

            (New-Object System.Media.SoundPlayer $sound).PlaySync()
        }
        
        Start-Sleep -Seconds (60 * (Get-Random -Min 5 -Max 15))
    }
}
