#Requires -Module PsQuickform

Add-Type -AssemblyName System.Speech
$script:Voice = New-Object System.Speech.Synthesis.SpeechSynthesizer
$global:AnnoyingPlayer = New-Object System.Media.SoundPlayer
$script:MyError = @()
$script:ProgressIds = @()
$script:DoNotInterrupt = $true
$script:TimeOut = 15

[System.Console]::add_CancelKeyPress({
    $global:AnnoyingPlayer.Stop()
})

Register-EngineEvent `
    -SourceIdentifier `
        PowerShell.Exiting `
    -Action {
        Write-Bitmap `
            -Path "$PsScriptRoot/../res/pic/todd-emote-color-20.png" `
            -XScale 2 |
        Write-Host

        $player = New-Object System.Media.SoundPlayer
        $player.SoundLocation =
            "$PsScriptRoot/../res/off-i-go-then_-_175speed.wav"
        $player.PlaySync()
    } |
    Out-Null

Set-Variable `
    -Scope 'Script' `
    -Name 'Annoy' `
    -Value $true

function Stop-TalkingPlease {
    [Alias("Stop")]
    Param()
    $Voice.SpeakAsyncCancelAll()
    Stop-AnnoyingPlayer -Force
    [void] $Voice.SpeakAsync("Okay I'll stop")
}

function Stop-AnnoyingPlayer {
    Param(
        [Switch]
        $Force
    )

    if (-not $Force -and $script:DoNotInterrupt) {
        return
    }

    $global:AnnoyingPlayer.Stop()
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

    Begin {
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

        if (-not $script:DoNotInterrupt) {
            $global:AnnoyingPlayer.SoundLocation =
                dir "$PsScriptRoot/../res/progress/*.wav" |
                Get-Random

            $global:AnnoyingPlayer.Play()
            $script:DoNotInterrupt = $true
        }
    }

    Process {
        try {
            $steppablePipeline.Process($_)
        } catch {
            throw
        }
    }

    End {
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
                $global:AnnoyingPlayer.Stop()

                $global:AnnoyingPlayer.SoundLocation =
                    dir "$PsScriptRoot/../res/upgrade-complete.wav"

                $global:AnnoyingPlayer.Play()
            }
        }
    }

<#
.ForwardHelpTargetName Microsoft.PowerShell.Utility\Write-Progress
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
            $script:DoNotInterrupt = $true
            $global:AnnoyingPlayer = New-Object System.Media.SoundPlayer
            $global:AnnoyingPlayer.SoundLocation =
                dir "$PsScriptRoot/../res/hurry-up.wav"
            $global:AnnoyingPlayer.Play()
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
        Stop-AnnoyingPlayer

        Set-Variable `
            -Scope 'Script' `
            -Name 'DoNotInterrupt' `
            -Value $false

        $annoy = (Get-Variable -Scope 'Script' -Name 'Annoy').Value

        if ($annoy -and $error.Count -gt 0) {
            $info = $error.CategoryInfo

            if ($info.Reason -like "ParameterBinding*") {
                Import-Module PsQuickform

                foreach ($msg in @("Okay, it looks like you need help " +
                    "calling a commandlet properly")
                ) {
                    [void] $Voice.SpeakAsync($msg)
                }

                try {
                    $timerEvents = Send-HurryUp `
                        -Interval ($script:TimeOut * 1000)

                    Set-Variable `
                        -Scope 'Global' `
                        -Name 'QformResult' `
                        -Value (Invoke-QformCommand `
                            -CommandName $info.Activity)

                    foreach ($event in $timerEvents) {
                        Unregister-Event -SourceIdentifier $event.Name
                    }

                    foreach ($msg in @("Result saved to Q Form Result")) {
                        [void] $Voice.SpeakAsync($msg)
                    }
                }
                catch {
                    Set-Variable `
                        -Scope 'Global' `
                        -Name 'AnnoyingError' `
                        -Value $PsItem

                    foreach ($msg in @("An error occurred. Result saved to Annoying Error")) {
                        [void] $Voice.SpeakAsync($msg)
                    }
                }
            }
            elseif ((Get-Random -Min 1 -Max 20) -eq 1) {
                foreach ($msg in @("Oh no", "Our table", "It's broken")) {
                    [void] $Voice.SpeakAsync($msg)
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
    [CmdletBinding(
        DefaultParameterSetName = 'AsString',
        HelpUri = 'https://go.microsoft.com/fwlink/?LinkID=2096610'
    )]
    Param(
        [Parameter(
            Position = 0,
            ValueFromRemainingArguments = $true
        )]
        [AllowNull()]
        [System.Object]
        ${Prompt},

        [Parameter(
            ParameterSetName = 'AsSecureString'
        )]
        [Switch]
        ${AsSecureString},

        [Parameter(
            ParameterSetName = 'AsString'
        )]
        [Switch]
        ${MaskInput}
    )

    Begin
    {
        $timerEvents = Send-HurryUp -Interval ($script:TimeOut * 1000)
        $script:annoy = $true

        try {
            $outBuffer = $null

            if ($PSBoundParameters.TryGetValue(
                'OutBuffer',
                [ref]$outBuffer
            )) {
                $PSBoundParameters['OutBuffer'] = 1
            }

            $wrappedCmd =
                $ExecutionContext.InvokeCommand.GetCommand(
                    'Microsoft.PowerShell.Utility\Read-Host',
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

    Process
    {
        try {
            $steppablePipeline.Process($PsItem)
        }
        catch {
            throw
        }
    }

    End
    {
        try {
            $steppablePipeline.End()
        }
        catch {
            throw
        }

        foreach ($event in $timerEvents) {
            Unregister-Event -SourceIdentifier $event.Name
        }
    }

    Clean
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

function Get-Help {
    [CmdletBinding(
        DefaultParameterSetName = 'AllUsersView',
        HelpUri = 'https://go.microsoft.com/fwlink/?LinkID=2096483'
    )]
    Param(
        [Parameter(
            Position = 0,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [String]
        ${Name},

        [String]
        ${Path},

        [ValidateSet(
            'Alias', 'Cmdlet', 'Provider', 'General', 'FAQ', 'Glossary',
            'HelpFile', 'ScriptCommand', 'Function', 'Filter',
            'ExternalScript', 'All', 'DefaultHelp', 'DscResource', 'Class',
            'Configuration'
        )]
        [String[]]
        ${Category},

        [Parameter(
            ParameterSetName = 'DetailedView',
            Mandatory = $true
        )]
        [Switch]
        ${Detailed},

        [Parameter(
            ParameterSetName = 'AllUsersView'
        )]
        [Switch]
        ${Full},

        [Parameter(
            ParameterSetName = 'Examples',
            Mandatory = $true
        )]
        [Switch]
        ${Examples},

        [Parameter(
            ParameterSetName = 'Parameters',
            Mandatory = $true
        )]
        [String[]]
        ${Parameter},

        [String[]]
        ${Component},

        [String[]]
        ${Functionality},

        [String[]]
        ${Role},

        [Parameter(
            ParameterSetName = 'Online',
            Mandatory = $true
        )]
        [Switch]
        ${Online},

        [Parameter(
            ParameterSetName = 'ShowWindow',
            Mandatory = $true
        )]
        [Switch]
        ${ShowWindow}
    )

    Begin {
        try {
            Write-Host "Oh, you want help, do you?"
            # todo
            toddlaugh

            $outBuffer = $null

            if ($PSBoundParameters.TryGetValue(
                'OutBuffer',
                [ref]$outBuffer
            )) {
                $PSBoundParameters['OutBuffer'] = 1
            }

            $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand(
                'Microsoft.PowerShell.Core\Get-Help',
                [System.Management.Automation.CommandTypes]::Cmdlet
            )

            $scriptCmd = { & $wrappedCmd @PSBoundParameters }

            $steppablePipeline = $scriptCmd.GetSteppablePipeline(
                $myInvocation.CommandOrigin
            )

            $steppablePipeline.Begin($PSCmdlet)
        } catch {
            throw
        }
    }

    Process {
        try {
            $steppablePipeline.Process($_)
        } catch {
            throw
        }
    }

    End {
        try {
            $steppablePipeline.End()
        } catch {
            throw
        }
    }

    Clean {
        if ($null -ne $steppablePipeline) {
            $steppablePipeline.Clean()
        }
    }

<#
.ForwardHelpTargetName Microsoft.PowerShell.Core\Get-Help
.ForwardHelpCategory Cmdlet
#>
}
