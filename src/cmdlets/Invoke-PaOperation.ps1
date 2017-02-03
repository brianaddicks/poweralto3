function Invoke-PaOperation {
    [CmdletBinding()]
	Param (
		[Parameter(Mandatory=$False,Position=0)]
		[string]$Command
    )

    $VerbosePrefix = "Invoke-PaOperation:"

    $CheckConnection = $global:PaDeviceObject.checkConnectionStatus($VerbosePrefix)

    return $global:PaDeviceObject.invokeOperationalQuery($Command)
}