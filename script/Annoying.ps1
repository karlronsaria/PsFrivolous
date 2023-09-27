Add-Type -AssemblyName System.Speech
$script:Voice = New-Object System.Speech.Synthesis.SpeechSynthesizer

function Stop-TalkingPlease {
    [Alias("Stop")]
    Param()
    $Voice.SpeakAsyncCancelAll()
    [void] $Voice.SpeakAsync("Okay I'll stop")
}

function Write-Output {
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

        [void] $Voice.SpeakAsync(($list -join ' '))
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
            if ((Get-Random -Min 1 -Max 20) -eq 1) {
                @("Oh no", "Our table", "It's broken") | foreach {
                    [void] $Voice.SpeakAsync($_)
		}
	    }
	    else {
                $MyError = $error
                $player = New-Object System.Media.SoundPlayer
                $player.SoundLocation =
                    dir "$PsScriptRoot/../res/oh-no-our-table.wav"
                $player.Play()
	    }
        }

        $error.Clear()
        Prompt-Frivolous -Name "PSHell" -Color "Red"
    }
}

