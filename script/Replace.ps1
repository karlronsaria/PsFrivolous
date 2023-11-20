function Compare-Object {
    [CmdletBinding(
        HelpUri = 'https://go.microsoft.com/fwlink/?LinkID=2096605',
        RemotingCapability = 'None'
    )]
    Param(
        [Parameter(
            Mandatory = $true,
            Position = 0
        )]
        [AllowEmptyCollection()]
        [PsObject[]]
        ${ReferenceObject},

        [Parameter(
            Mandatory = $true,
            Position = 1,
            ValueFromPipeline = $true
        )]
        [AllowEmptyCollection()]
        [PsObject[]]
        ${DifferenceObject},

        [ValidateRange(0, 2147483647)]
        [Int]
        ${SyncWindow},

        [System.Object[]]
        ${Property},

        [Switch]
        ${ExcludeDifferent},

        [Switch]
        ${IncludeEqual},

        [Switch]
        ${PassThru},

        [String]
        ${Culture},

        [Switch]
        ${CaseSensitive}
    )

    try {
        $outBuffer = $null

        if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer)) {
            $PSBoundParameters['OutBuffer'] = 1
        }

        $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand(
            'Microsoft.PowerShell.Utility\Compare-Object',
            [System.Management.Automation.CommandTypes]::Cmdlet
        )

        & $wrappedCmd @PSBoundParameters | foreach {
            $_.SideIndicator = switch ($_.SideIndicator) {
                "=>" { "-->>" }
                "<=" { "<<--" }
            }

            $_
        }
    } catch {
        throw
    }

<#
.ForwardHelpTargetName Microsoft.PowerShell.Utility\Compare-Object
.ForwardHelpCategory Cmdlet
#>
}
