#Requires -Module PsQuickform

Add-Type -AssemblyName System.Speech
$script:Voice = New-Object System.Speech.Synthesis.SpeechSynthesizer
$script:AnnoyingPlayer = New-Object System.Media.SoundPlayer
$script:MyError = @()
$script:ProgressIds = @()
$script:IsPlaying = $true

[System.Console]::add_CancelKeyPress({
    $script:AnnoyingPlayer.Stop()
})

Set-Variable `
    -Scope 'Script' `
    -Name 'Annoy' `
    -Value $true

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

            if ($PSBoundParameters.TryGetValue(
                'OutBuffer',
                [ref]$outBuffer
            )) {
                $PSBoundParameters['OutBuffer'] = 1
            }

            $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand(
                'Microsoft.PowerShell.Utility\Write-Output',
                [System.Management.Automation.CommandTypes]::Cmdlet
            )

            $scriptCmd = { & $wrappedCmd @PSBoundParameters }

            $steppablePipeline = $scriptCmd.GetSteppablePipeline(
                $myInvocation.CommandOrigin
            )

            $steppablePipeline.Begin($PSCmdlet)
        }
        catch {
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

function Remove-Item {
    [CmdletBinding(
        DefaultParameterSetName = 'Path',
        SupportsShouldProcess = $true,
        ConfirmImpact = 'Medium',
        SupportsTransactions = $true,
        HelpUri = 'https://go.microsoft.com/fwlink/?LinkID=113373'
    )]
    param(
        [Parameter(
            ParameterSetName = 'Path',
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string[]]
        ${Path},

        [Parameter(
            ParameterSetName = 'LiteralPath',
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Alias('PSPath')]
        [string[]]
        ${LiteralPath},

        [string]
        ${Filter},

        [string[]]
        ${Include},

        [string[]]
        ${Exclude},

        [switch]
        ${Recurse},

        [switch]
        ${Force},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [pscredential]
        [System.Management.Automation.CredentialAttribute()]
        ${Credential}
    )

    dynamicparam {
        try {
            $targetCmd = $ExecutionContext.InvokeCommand.GetCommand(
                'Microsoft.PowerShell.Management\Remove-Item',
                [System.Management.Automation.CommandTypes]::Cmdlet,
                $PSBoundParameters
            )

            $dynamicParams = @(
                $targetCmd.Parameters.GetEnumerator() |
                Microsoft.PowerShell.Core\Where-Object { $_.Value.IsDynamic }
            )

            if ($dynamicParams.Length -gt 0) {
                $paramDictionary =
                [Management.Automation.RuntimeDefinedParameterDictionary]::
                new()

                foreach ($param in $dynamicParams) {
                    $param = $param.Value

                    if (-not $MyInvocation.MyCommand.Parameters.ContainsKey(
                        $param.Name
                    )) {
                        $dynParam =
                            [Management.Automation.RuntimeDefinedParameter]::
                            new(
                                $param.Name,
                                $param.ParameterType,
                                $param.Attributes
                            )

                        $paramDictionary.Add($param.Name, $dynParam)
                    }
                }

                return $paramDictionary
            }
        } catch {
            throw
        }
    }

    begin {
        try {
            $outBuffer = $null

            if ($PSBoundParameters.TryGetValue(
                'OutBuffer',
                [ref]$outBuffer
            )) {
                $PSBoundParameters['OutBuffer'] = 1
            }

            $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand(
                'Microsoft.PowerShell.Management\Remove-Item',
                [System.Management.Automation.CommandTypes]::Cmdlet
            )

            $scriptCmd = { & $wrappedCmd @PSBoundParameters }

            $steppablePipeline = $scriptCmd.GetSteppablePipeline(
                $myInvocation.CommandOrigin
            )

            $steppablePipeline.Begin($PSCmdlet)
        }
        catch {
            throw
        }
    }

    process {
        try {
            $steppablePipeline.Process($_)
        } catch {
            throw
        }
    }

    end {
        try {
            $steppablePipeline.End()
        } catch {
            throw
        }

        $player = New-Object System.Media.SoundPlayer
        $player.SoundLocation =
            dir "$PsScriptRoot/../res/fireball.wav"
        $player.Play()
    }

<#
.ForwardHelpTargetName Microsoft.PowerShell.Management\Remove-Item
.ForwardHelpCategory Cmdlet
#>
}

function Write-Progress {
    [CmdletBinding(
        HelpUri = 'https://go.microsoft.com/fwlink/?LinkID=113428',
        RemotingCapability = 'None'
    )]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]
        ${Activity},

        [Parameter(Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Status},

        [Parameter(Position = 2)]
        [ValidateRange(0, 2147483647)]
        [int]
        ${Id},

        [ValidateRange(-1, 100)]
        [int]
        ${PercentComplete},

        [int]
        ${SecondsRemaining},

        [string]
        ${CurrentOperation},

        [ValidateRange(-1, 2147483647)]
        [int]
        ${ParentId},

        [switch]
        ${Completed},

        [int]
        ${SourceId}
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

            $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand(
                'Microsoft.PowerShell.Utility\Write-Progress',
                [System.Management.Automation.CommandTypes]::Cmdlet
            )

            $scriptCmd = { & $wrappedCmd @PSBoundParameters }

            $steppablePipeline = $scriptCmd.GetSteppablePipeline(
                $myInvocation.CommandOrigin
            )

            $steppablePipeline.Begin($PSCmdlet)
        }
        catch {
            throw
        }

        $myId = if ($null -eq $Id) { -1 } else { $ID }

        if ($myId -notIn $script:ProgressIds) {
            $script:ProgressIds += @($myId)
        }

        if (-not $script:IsPlaying) {
            $script:AnnoyingPlayer.SoundLocation =
                dir "$PsScriptRoot/../res/progress/*.wav" |
                Get-Random

            $script:IsPlaying = $true
        }
    }

    process {
        try {
            $steppablePipeline.Process($_)
        } catch {
            throw
        }
    }

    end {
        try {
            $steppablePipeline.End()
        } catch {
            throw
        }

        if ($Completed -or $PercentComplete -ge 100) {
            $script:ProgressIds = @($script:ProgressIds | where {
                $_ -ne $myId
            })

            if (@($script:ProgressIds).Count -eq 0) {
                $script:AnnoyingPlayer.Stop()

                $script:AnnoyingPlayer.SoundLocation =
                    dir "$PsScriptRoot/../res/upgrade-complete.wav"

                $script:AnnoyingPlayer.Play()
            }
        }
    }

<#
.ForwardHelpTargetName Microsoft.PowerShell.Utility\Write-Progress
.ForwardHelpCategory Cmdlet
#>
}

function ForEach-Object {
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

        $script:AnnoyingPlayer.SoundLocation =
            dir "$PsScriptRoot/../res/progress/*.wav" |
            Get-Random

        $script:AnnoyingPlayer.PlayLooping()
        $script:IsPlaying = $true
        $list = @()
    }

    process {
        try {
            $steppablePipeline.Process($_)
        } catch {
            # throw
            $list += @([System.Management.Automation.ErrorRecord](
                $_.PsObject.Copy()
            ))
        }
    }

    end {
        $script:AnnoyingPlayer.Stop()

        Set-Variable `
            -Scope 'Script' `
            -Name 'Annoy' `
            -Value $false

        $max_blasts = 4

        if ($list.Count -gt 1) {
            Write-Host "Oh no."
            $script:AnnoyingPlayer.SoundLocation =
                dir "$PsScriptRoot/../res/just-works.wav"
            $script:AnnoyingPlayer.PlaySync()
        }

        for ($i = 0; $i -lt ($list.Count - 1) -and $i -lt $max_blasts; ++$i) {
            Write-Error $list[$i]
            $script:AnnoyingPlayer.SoundLocation =
                dir "$PsScriptRoot/../res/shotgun-reload.wav"
            $script:AnnoyingPlayer.PlaySync()
        }

        if ($i -lt ($list.Count - 1)) {
            Write-Error $list[$i]
            $script:AnnoyingPlayer.SoundLocation =
                dir "$PsScriptRoot/../res/shotgun-staccato.wav"
            $script:AnnoyingPlayer.Play()
            # Start-Sleep -Milliseconds 800
            ++$i

            for (; $i -lt ($list.Count); ++$i) {
                Write-Error $list[$i]
            }
        }
        elseif ($i -lt $list.Count) {
            Write-Error $list[$i]
            $script:AnnoyingPlayer.SoundLocation =
                dir "$PsScriptRoot/../res/shotgun-blast.wav"
            $script:AnnoyingPlayer.PlaySync()
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

function Send-RandomDistress {
    $player = New-Object System.Media.SoundPlayer

    $player.SoundLocation =
        dir "$PsScriptRoot/../res/distress/*.wav" |
        Get-Random

    $player.Play()
}

function Send-HurryUp {
    Param(
        [Int]
        $Interval
    )

    $timer = New-Object System.Timers.Timer
    $timer.Interval = $Interval
    $timer.Enabled = $true
    $timer.AutoReset = $false

    Register-ObjectEvent `
        -InputObject $timer `
        -EventName 'Elapsed' `
        -Action {
            $script:IsPlaying = $true
            $script:AnnoyingPlayer = New-Object System.Media.SoundPlayer
            $script:AnnoyingPlayer.SoundLocation =
                dir "$PsScriptRoot/../res/hurry-up.wav"
            $script:AnnoyingPlayer.Play()
        }

    Register-ObjectEvent `
        -InputObject $timer `
        -EventName 'Elapsed' `
        -Action {
            $pos = $host.UI.RawUI.CursorPosition
            $pos2 = $pos
            $pos2.x = 0
            $pos2.y = 0
            $host.UI.RawUI.CursorPosition = $pos2

            (Get-BoxDrawnText -Message "HURRY UP!") -split "`n" |
                foreach {
                    $_ | Write-Host
                    Start-Sleep -Milliseconds 40
                }

            $host.UI.RawUI.CursorPosition = $pos
        }

    return @($timer.Start())
}

function global:Set-PromptAnnoying {
    Set-Item Function:\prompt -Value {
        if (-not $script:IsPlaying) {
            $script:AnnoyingPlayer.Stop()
        }

        $script:IsPlaying = $false
        $annoy = (Get-Variable -Scope 'Script' -Name 'Annoy').Value

        if ($annoy -and $error.Count -gt 0) {
            $info = $error.CategoryInfo

            if ($info.Reason -like "ParameterBinding*") {
                Import-Module PsQuickform

                @("Okay, it looks like you need help calling a " +
                  "commandlet properly") |
                foreach {
                    [void] $Voice.SpeakAsync($_)
                }

                try {
                    $timer = Send-HurryUp -Interval (15 * 1000)

                    Set-Variable `
                        -Scope 'Global' `
                        -Name 'QformResult' `
                        -Value (Invoke-QformCommand `
                            -CommandName $info.Activity)

                    foreach ($event in $timer) {
                        Unregister-Event -SourceIdentifier $_.Name
                    }

                    @("Result saved to Q Form Result") |
                    foreach {
                        [void] $Voice.SpeakAsync($_)
                    }
                }
                catch {
                    Set-Variable `
                        -Scope 'Global' `
                        -Name 'AnnoyingError' `
                        -Value $_

                    @("An error occurred. Result saved to Annoying Error") |
                    foreach {
                        [void] $Voice.SpeakAsync($_)
                    }
                }
            }
            elseif ((Get-Random -Min 1 -Max 20) -eq 1) {
                @("Oh no", "Our table", "It's broken") |
                foreach {
                    [void] $Voice.SpeakAsync($_)
                }
            }
            else {
                Send-RandomDistress
            }

            Set-Variable `
                -Scope 'Script' `
                -Name 'Annoy' `
                -Value $true

            $MyError = $error
        }

        Set-Variable `
            -Scope 'Script' `
            -Name 'Annoy' `
            -Value $true

        $error.Clear()
        Prompt-Frivolous -Name "PSHell" -Color "Red"
    }
}

function Read-Host {
    [CmdletBinding(DefaultParameterSetName='AsString', HelpUri='https://go.microsoft.com/fwlink/?LinkID=2096610')]
    param(
        [Parameter(Position=0, ValueFromRemainingArguments=$true)]
        [AllowNull()]
        [System.Object]
        ${Prompt},

        [Parameter(ParameterSetName='AsSecureString')]
        [switch]
        ${AsSecureString},

        [Parameter(ParameterSetName='AsString')]
        [switch]
        ${MaskInput}
    )

    begin
    {
        $timerEvents = Send-HurryUp -Interval (15 * 1000)

        try {
            $outBuffer = $null
            if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
            {
                $PSBoundParameters['OutBuffer'] = 1
            }

            $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Utility\Read-Host', [System.Management.Automation.CommandTypes]::Cmdlet)
            $scriptCmd = {& $wrappedCmd @PSBoundParameters }

            $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
            $steppablePipeline.Begin($PSCmdlet)
        } catch {
            throw
        }
    }

    process
    {
        try {
            $steppablePipeline.Process($_)
        } catch {
            throw
        }
    }

    end
    {
        try {
            $steppablePipeline.End()
        } catch {
            throw
        }

        foreach ($event in $timerEvents) {
            Unregister-Event -SourceIdentifier $event.Name
        }
    }

    clean
    {
        if ($null -ne $steppablePipeline) {
            $steppablePipeline.Clean()
        }
    }

<#
.ForwardHelpTargetName Microsoft.PowerShell.Utility\Read-Host
.ForwardHelpCategory Cmdlet
#>
}

