function Get-PaVsys {
    [CmdletBinding()]
	Param (
    )
    
    $VerbosePrefix = "Get-PaVsys:"

    if ($global:PaDeviceObject.Connected) {
        # Get the data
        $Operation = '<show><system><state><filter-pretty>cfg.dns-vsys</filter-pretty></state></system></show>'
        $Result = Invoke-PaOperation $Operation
        
        # Sanatize it and add it to the array
        $Result = $Result.response.result.'#cdata-section' -replace "cfg.dns-vsys: ",""
        $Rx = [regex] "(.+?):"
        $Matches = $Rx.Matches($Result)
        $ReturnObject = @()
        foreach ($Match in $Matches) {
            $ReturnObject += ($Match.Groups[1].Value).Trim()
        }

        return $ReturnObject
    } else {
        Throw "$VerbosePrefix Not Connected, please use Get-PaConfig to connect before using other cmdlets."
    }
}