function Set-PaConfig {
	Param (
		[Parameter(Mandatory=$True,Position=0,ParameterSetName="manual")]
		[string]$Xpath = "/config",

        [Parameter(Mandatory=$True,Position=1,ParameterSetName="manual")]
		[string]$ElementAsString,

        [Parameter(Mandatory=$True,Position=1,ParameterSetName="object",ValueFromPipeline=$true)]
		$PaObject
    )
    
    $VerbosePrefix = "Set-PaConfig:"

    if ($global:PaDeviceObject.Connected) {
        if ($PaObject) {
            Write-Verbose "$VerbosePrefix Getting info from Object"

            $ElementAsString = $PaObject.PrintPlainXml()
            $Xpath           = $PaObject.getXPath()
            
            Write-Verbose "$VerbosePrefix Element: $ElementAsString"
            Write-Verbose "$VerbosePrefix Xpath: $Xpath"
        }
        return $global:PaDeviceObject.invokeConfigQuery($Xpath,"set",$ElementAsString)
    } else {
        Throw "$VerbosePrefix Not Connected, please use Get-PaConfig to connect before using other cmdlets."
    }
}