function Write-What {
    [CmdletBinding(
        HelpUri = 'https://go.microsoft.com/fwlink/?LinkID=113427',
        RemotingCapability = 'None'
    )]
    param(
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromRemainingArguments = $true
        )]
        [AllowNull()]
        [AllowEmptyCollection()]
        [psobject[]]
        ${InputObject},

        [switch]
        ${NoEnumerate}
    )

    begin {
        try {
            $outBuffer = $null

            if ($PSBoundParameters.TryGetValue( `
                'OutBuffer', `
                [ref]$outBuffer `
            )) {
                $PSBoundParameters['OutBuffer'] = 1
            }

            $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand( `
                'Microsoft.PowerShell.Utility\Write-Output', `
                [System.Management.Automation.CommandTypes]::Cmdlet `
            )

            $scriptCmd = { & $wrappedCmd @PSBoundParameters }

            $steppablePipeline = $scriptCmd.GetSteppablePipeline( `
                $myInvocation.CommandOrigin `
            )

            $steppablePipeline.Begin($PSCmdlet)
        } catch {
            throw
        }

        $voice = New-Object -ComObject Sapi.SpVoice
        $voice.Rate = 0
        $list = @()
    }

    process {
        try {
            $steppablePipeline.Process($_)
        } catch {
            throw
        }

        $list += @($InputObject)
    }

    end {
        try {
            $steppablePipeline.End()
        } catch {
            throw
        }

        [void] $voice.Speak(($list -join ' '))
    }

<#
.ForwardHelpTargetName Microsoft.PowerShell.Utility\Write-Output
.ForwardHelpCategory Cmdlet
#>
}

$script:MyError = @()

function global:Set-PromptAnnoying {
    Set-Item Function:\prompt -Value {
        if ($error.Count -gt 0) {
            $MyError = $error
            $player = New-Object System.Media.SoundPlayer
            $player.SoundLocation =
                dir "$PsScriptRoot/../res/oh-no-our-table.wav"
            $player.Play()
        }

        $error.Clear()
        Prompt-Frivolous -Name "PSHell" -Color "Red"
    }
}

