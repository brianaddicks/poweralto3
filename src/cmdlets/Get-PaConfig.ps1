function Get-PaConfig {
	Param (
        [Parameter(Mandatory=$False,Position=0)]
		[string]$Xpath = "/config",

        [Parameter(Mandatory=$False,Position=1)]
		[string]$Vsys,

        [Parameter(Mandatory=$False,Position=2)]
		[string]$Device,

        [Parameter(Mandatory=$False,Position=3)]
        [ValidateSet("get","show")]
        [string]$Action = "show"
    )
    
    $VerbosePrefix = "Get-PaConfig:"

    if ($global:PaDeviceObject.Connected) {
        $ConfigObject = New-Object PaConfigObject
        
        $XpathRx    = [regex] "\/config(\/devices\/entry\[@name='(?<device>.+?)'\])?(\/vsys\/entry\[@name='(?<vsys>.+?)'\])?(?<node>.+)?"
        $XpathMatch = $XpathRx.Match($Xpath)
        if ($XpathMatch.Success) {
            $ConfigObject.Vsys       = $XpathMatch.Groups['vsys'].Value
            $ConfigObject.Device     = $XpathMatch.Groups['device'].Value
            $ConfigObject.ConfigNode = $XpathMatch.Groups['node'].Value
            $global:testobject = $ConfigObject
        } else {
            Throw "$VerbosePrefix Xpath Invalid"
        }

        $Response = $global:PaDeviceObject.invokeConfigQuery($ConfigObject.getXPath(),$Action)

        return $ConfigObject
    } else {
        Throw "$VerbosePrefix Not Connected, please use Get-PaDevice to connect before using other cmdlets."
    }
}