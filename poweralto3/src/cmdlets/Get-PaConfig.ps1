function Get-PaConfig {
    [CmdletBinding()]
	Param (
        [Parameter(Mandatory=$False,Position=0)]
		[string]$XPath = "/config",

        [Parameter(Mandatory=$False,Position=3)]
        [ValidateSet("get","show")]
        [string]$Action = "show"
    )
    
    $VerbosePrefix = "Get-PaConfig:"

    if ($global:PaDeviceObject.Connected) {
        $Response = $global:PaDeviceObject.invokeConfigQuery($XPath,$Action)

        return $Response
    } else {
        Throw "$VerbosePrefix Not Connected, please use Get-PaDevice to connect before using other cmdlets."
    }
}