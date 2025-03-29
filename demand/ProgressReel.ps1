<#
.DESCRIPTION
Tags: ProgressReel
#>

Add-Type -Path "$PsScriptRoot/../lib/Reel/bin/release/net9.0-windows/Reel.dll"
$global:progressReel = @()

function Write-Progress {
    [CmdletBinding(HelpUri='https://go.microsoft.com/fwlink/?LinkID=2097036', RemotingCapability='None')]
    param(
        [Parameter(Position=0)]
        [string]
        ${Activity},

        [Parameter(Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Status},

        [Parameter(Position=2)]
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

    begin
    {
        try {
            $outBuffer = $null
            if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
            {
                $PSBoundParameters['OutBuffer'] = 1
            }

            if (-not $global:progressReel) {
                $global:progressReel = Get-ChildItem "$($env:USERPROFILE)/Videos/reel/*" -Directory |
                    Get-Random |
                    Get-ChildItem |
                    where Name -eq 'img' |
                    Get-ChildItem -File
            }

            $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Utility\Write-Progress', [System.Management.Automation.CommandTypes]::Cmdlet)
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

            $index = [math]::Floor($PercentComplete * $global:progressReel.Count / 100)
            $null = [Reel.ImageWindow]::SetImageAsync($global:progressReel[$index])

            # [Reel.ImageWindow]::SetWidthAsync($PercentComplete * 5)

            if (-not [Reel.ImageWindow]::Visible) {
                sleep 0.1
                [Reel.ImageWindow]::UnhideWindow()
            }
        } catch {
            throw
        }
    }

    end
    {
        if ($Completed) {
            [Reel.ImageWindow]::HideWindow()

            $global:progressReel = Get-ChildItem "$($env:USERPROFILE)/Videos/reel/*" -Directory |
                Get-Random |
                Get-ChildItem |
                where Name -eq 'img' |
                Get-ChildItem -File
        }

        try {
            $steppablePipeline.End()
        } catch {
            throw
        }
    }

    clean
    {
        if ($null -ne $steppablePipeline) {
            $steppablePipeline.Clean()
        }
    }

<#
.ForwardHelpTargetName Microsoft.PowerShell.Utility\Write-Progress
.ForwardHelpCategory Cmdlet
#>
}

