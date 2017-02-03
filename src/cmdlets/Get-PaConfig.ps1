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
        $Response = $global:PaDeviceObject.invokeConfigQuery($Xpath,$Action)

        $rx = [regex] "\/.+?vsys\/entry.+?\/(.+)"
        $ConfigObject = new-Object PaConfigObject
        $XPathNode = $rx.Match($Xpath).Groups[1].Value
        $Global:TestObject = "" | Select XPathNode,ManualXml
        $Global:TestObject.XPathNode = $XPathNode

        $ConfigObject.XpathNode = $XPathNode
        $ConfigObject.ManualXml = $Response.response.result.$XPathNode.InnerXml
        return $ConfigObject
    } else {
        Throw "$VerbosePrefix Not Connected, please use Get-PaConfig to connect before using other cmdlets."
    }
}