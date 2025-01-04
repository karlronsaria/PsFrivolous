filter ForEach-Object {
    [CmdletBinding(
        DefaultParameterSetName = 'ScriptBlockSet',
        SupportsShouldProcess = $true,
        ConfirmImpact = 'Medium',
        HelpUri = 'https://go.microsoft.com/fwlink/?LinkID=113300',
        RemotingCapability = 'None'
    )]
    param(
        [Parameter(
            ParameterSetName = 'ScriptBlockSet',
            ValueFromPipeline = $true
        )]
        [Parameter(
            ParameterSetName = 'PropertyAndMethodSet',
            ValueFromPipeline = $true
        )]
        [psobject]
        ${InputObject},

        [Parameter(
            ParameterSetName = 'ScriptBlockSet'
        )]
        [scriptblock]
        ${Begin},

        [Parameter(
            ParameterSetName = 'ScriptBlockSet',
            Mandatory = $true,
            Position = 0
        )]
        [AllowNull()]
        [AllowEmptyCollection()]
        [scriptblock[]]
        ${Process},

        [Parameter(
            ParameterSetName = 'ScriptBlockSet'
        )]
        [scriptblock]
        ${End},

        [Parameter(
            ParameterSetName = 'ScriptBlockSet',
            ValueFromRemainingArguments = $true
        )]
        [AllowNull()]
        [AllowEmptyCollection()]
        [scriptblock[]]
        ${RemainingScripts},

        [Parameter(
            ParameterSetName = 'PropertyAndMethodSet',
            Mandatory = $true,
            Position = 0
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        ${MemberName},

        [Parameter(
            ParameterSetName = 'PropertyAndMethodSet',
            ValueFromRemainingArguments = $true
        )]
        [Alias('Args')]
        [System.Object[]]
        ${ArgumentList}
    )

    begin {
        try {
            $outBuffer = $null

            if ($PSBoundParameters.TryGetValue(
                'OutBuffer',
                [ref]$outBuffer
            )) {
                $PSBoundParameters['OutBuffer'] = 1
            }

            $wrappedCmd = $ExecutionContext.
                InvokeCommand.
                GetCommand(
                    'Microsoft.PowerShell.Core\ForEach-Object',
                    [System.Management.Automation.CommandTypes]::Cmdlet
                )

            $scriptCmd = { & $wrappedCmd @PSBoundParameters }

            $steppablePipeline = $scriptCmd.
                GetSteppablePipeline($myInvocation.CommandOrigin)

            $steppablePipeline.Begin($PSCmdlet)
        } catch {
            throw
        }

        # $script:AnnoyingPlayer.SoundLocation =
        #     dir "$PsScriptRoot/../res/progress/*.wav" |
        #     Get-Random

        # $script:AnnoyingPlayer.PlayLooping()
        # $script:DoNotInterrupt = $true

        $list = @()
    }

    process {
        try {
            $steppablePipeline.Process($PsItem)
        } catch {
            # throw
            $list += @([System.Management.Automation.ErrorRecord](
                $PsItem.PsObject.Copy()
            ))
        }
    }

    end {
        Set-Variable `
            -Scope 'Script' `
            -Name 'Annoy' `
            -Value $true # todo

        $max_blasts = 4

        if ($list.Count -gt 1) {
            Write-Host "Oh no."
            $global:AnnoyingPlayer.Stop()
            $global:AnnoyingPlayer.SoundLocation =
                dir "$PsScriptRoot/../res/just-works.wav"
            $global:AnnoyingPlayer.PlaySync()
        }

        for ($i = 0; $i -lt ($list.Count - 1) -and $i -lt $max_blasts; ++$i) {
            Write-Error $list[$i]
            $global:AnnoyingPlayer.SoundLocation =
                dir "$PsScriptRoot/../res/shotgun-reload.wav"
            $global:AnnoyingPlayer.PlaySync()
        }

        if ($i -lt ($list.Count - 1)) {
            Write-Error $list[$i]
            $global:AnnoyingPlayer.SoundLocation =
                dir "$PsScriptRoot/../res/shotgun-staccato.wav"
            $global:AnnoyingPlayer.Play()
            # Start-Sleep -Milliseconds 800
            ++$i

            for (; $i -lt ($list.Count); ++$i) {
                Write-Error $list[$i]
            }
        }
        elseif ($i -lt $list.Count) {
            Write-Error $list[$i]
            $global:AnnoyingPlayer.SoundLocation =
                dir "$PsScriptRoot/../res/shotgun-blast.wav"
            $global:AnnoyingPlayer.PlaySync()
        }

        try {
            $steppablePipeline.End()
        } catch {
            # throw
        }

        $MyError = $error
        $error = @()
    }

<#
.ForwardHelpTargetName Microsoft.PowerShell.Core\ForEach-Object
.ForwardHelpCategory Cmdlet
#>
}

