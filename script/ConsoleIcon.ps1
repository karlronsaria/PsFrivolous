<#
.SYNOPSIS
Set the icon of the current console window to the specified icon

.DESCRIPTION

##############################################################################
##
## Script: Set-ConsoleIcon.ps1
## By: Aaron Lerch
## Website: www.aaronlerch.com/blog
##
## Set the icon of the current console window to the specified icon
##
## Usage:  Set-ConsoleIcon [string]
##
## ie:
##
## PS:1 > Set-ConsoleIcon "C:\Icons\special_powershell_icon.ico"
##
##############################################################################

.EXAMPLE
PS:1 > Set-ConsoleIcon "C:\Icons\special_powershell_icon.ico"

.LINK
* author
  - Url: <www.aaronlerch.com/blog>
  - Broken: 2026-05-14
  - Redirect: <https://medium.com/@aaronlerch>

.LINK
* howto: Invoke a Win32 P/Invoke call
  - By: Lee Holmes
  - Url: <http://www.leeholmes.com/blog/GetTheOwnerOfAProcessInPowerShellPInvokeAndRefOutParameters.aspx>
  - Broken: 2026-05-14
#>
function Set-ConsoleIcon {
    Param(
       [string]
       $IconPath
    )

    function Invoke-Win32 {
        Param(
            [string] $dllName,
            [Type] $returnType,
            [string] $methodName,
            [Type[]] $parameterTypes,
            [Object[]] $parameters
        )

        ## Begin to build the dynamic assembly
        $domain = [AppDomain]::CurrentDomain
        $name = New-Object Reflection.AssemblyName 'PInvokeAssembly'
        $assembly = $domain.DefineDynamicAssembly($name, 'Run')
        $module = $assembly.DefineDynamicModule('PInvokeModule')
        $type = $module.DefineType('PInvokeType', "Public,BeforeFieldInit")

        ## Go through all of the parameters passed to us.  As we do this,
        ## we clone the user's inputs into another array that we will use for
        ## the P/Invoke call.
        $inputParameters = @()
        $refParameters = @()

        for ($counter = 1; $counter -le $parameterTypes.Length; $counter++) {
            ## If an item is a PSReference, then the user
            ## wants an [out] parameter.
            if ($parameterTypes[$counter - 1] -eq [Ref]) {
                ## Remember which parameters are used for [Out] parameters
                $refParameters += $counter

                ## On the cloned array, we replace the PSReference type with the
                ## .Net reference type that represents the value of the PSReference,
                ## and the value with the value held by the PSReference.
                $parameterTypes[$counter - 1] =
                    $parameters[$counter - 1].Value.GetType().MakeByRefType()

                $inputParameters += $parameters[$counter - 1].Value
            }
            else {
                ## Otherwise, just add their actual parameter to the
                ## input array.
                $inputParameters += $parameters[$counter - 1]
            }
        }

        ## Define the actual P/Invoke method, adding the [Out]
        ## attribute for any parameters that were originally [Ref]
        ## parameters.
        $method = $type.DefineMethod(
            $methodName,
            'Public,HideBySig,Static,PinvokeImpl',
            $returnType,
            $parameterTypes
        )

        foreach ($refParameter in $refParameters) {
            $method.DefineParameter($refParameter, "Out", $null)
        }

        ## Apply the P/Invoke constructor
        $ctor = [Runtime.InteropServices.DllImportAttribute ].GetConstructor([string])
        $attr = New-Object Reflection.Emit.CustomAttributeBuilder $ctor, $dllName
        $method.SetCustomAttribute($attr)

        ## Create the temporary type, and invoke the method.
        $realType = $type.CreateType()

        $realType.InvokeMember(
            $methodName,
            'Public,Static,InvokeMethod',
            $null, $null, $inputParameters
        )

        ## Finally, go through all of the reference parameters, and update the
        ## values of the PSReference objects that the user passed in.
        foreach($refParameter in $refParameters) {
            $parameters[$refParameter - 1].Value = $inputParameters[$refParameter - 1]
        }
    }

    function Send-Message {
        Param(
            [IntPtr] $hWnd,
            [Int32] $message,
            [Int32] $wParam,
            [Int32] $lParam
        )

        $parameterTypes = [IntPtr], [Int32], [Int32], [Int32]
        $parameters = $hWnd, $message, $wParam, $lParam
        Invoke-Win32 "user32.dll" ([Int32]) "SendMessage" $parameterTypes $parameters
    }

    function Get-CurrentWindow {
        return Invoke-Win32 "kernel32" ([IntPtr]) "GetConsoleWindow"
    }

    $WM_SETICON = 0x80
    $ICON_SMALL = 0

    if (-not [System.IO.File]::Exists($IconPath)) {
        return "Icon file not found"
    }

    [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null
    $icon = New-Object System.Drawing.Icon($IconPath)

    if ($null -eq $icon) {
        return "Icon file could not be read"
    }

    $consoleHandle = Get-CurrentWindow
    Send-Message $consoleHandle $WM_SETICON $ICON_SMALL $icon.Handle | Out-Null
}

