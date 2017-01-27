function Get-PaConfig {
	Param (
		[Parameter(Mandatory=$False,Position=0)]
		[string]$Xpath = "/config",

        [Parameter(Mandatory=$False,Position=1)]
        [ValidateSet("get","show")]
        [string]$Action = "show"
    )
    
    $VerbosePrefix = "Get-PaConfig:"

    if ($global:PaDeviceObject.Connected) {
        return $global:PaDeviceObject.invokeConfigQuery($Xpath,$Action)
    } else {
        Throw "$VerbosePrefix Not Connected, please use Get-PaConfig to connect before using other cmdlets."
    }
}