function Get-PaRadiusProfile {
    [CmdletBinding()]
	Param (
		[Parameter(Mandatory=$False,Position=0)]
		[string]$Name,

        [Parameter(Mandatory=$False,Position=1)]
		[string]$Vsys = "shared",

        [Parameter(Mandatory=$False,Position=2)]
		[string]$Device
    )
    
    $VerbosePrefix = "Get-PaRadiusProfile:"

    if ($global:PaDeviceObject.Connected) {
        $InfoObject        = New-Object PaRadiusProfile
        $InfoObject.Name   = $Name
        $InfoObject.Vsys   = $Vsys
        $InfoObject.Device = $Device
        $Response          = Get-PaConfig $InfoObject.GetXpath()

        $ConfigNode = 'radius'

        $ReturnObject = @()
        foreach ($entry in $Response.response.result.$ConfigNode.entry) {
            $NewEntry      = New-Object PaRadiusProfile
            $ReturnObject += $NewEntry

            $NewEntry.Vsys   = $Vsys
            $NewEntry.Device = $Device

            $NewEntry.Name         = $entry.name
            $NewEntry.Timeout      = $entry.timeout
            $NewEntry.Retries      = $entry.retries
            $NewEntry.Servers      = @()

            $BoolProperties = @{ 'AdminUseOnly' = 'admin-use-only' }

            foreach ($Bool in $BoolProperties.GetEnumerator()) {
                $PsProp  = $Bool.Name
                $XmlProp = $Bool.Value
                $NewEntry.$PsProp = $entry.$XmlProp
            }

            foreach ($Server in $entry.server.entry) {
                $NewServer         = New-Object PaAuthServer
                $NewServer.Name    = $Server.name
                $NewServer.Server  = $Server.'ip-address'
                $NewServer.Port    = $Server.port
                $NewEntry.Servers += $NewServer
            }
        }
        return $ReturnObject
    } else {
        Throw "$VerbosePrefix Not Connected, please use Get-PaConfig to connect before using other cmdlets."
    }
}