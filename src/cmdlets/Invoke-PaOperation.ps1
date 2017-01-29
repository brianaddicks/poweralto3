function Invoke-PaOperation {
    [CmdletBinding()]
	Param (
		[Parameter(Mandatory=$False,Position=0)]
		[string]$Command
    )

    $VerbosePrefix = "Invoke-Pester:"

    $CheckConnection = $global:PaDeviceObject.checkConnectionStatus($VerbosePrefix)

    return $global:PaDeviceObject.invokeOperationalQuery($Command)
}