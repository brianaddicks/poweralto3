function Get-PaKerberosProfile {
	Param (
		[Parameter(Mandatory=$False,Position=0)]
		[string]$Name,

        [Parameter(Mandatory=$False,Position=1)]
		[string]$Vsys = "shared",

        [Parameter(Mandatory=$False,Position=2)]
		[string]$Device
    )
    
    $VerbosePrefix = "Get-PaKerberosProfile:"

    if ($global:PaDeviceObject.Connected) {
        $InfoObject        = New-Object PaKerberosProfile
        $InfoObject.Name   = $Name
        $InfoObject.Vsys   = $Vsys
        $InfoObject.Device = $Device
        $Response          = Get-PaConfig $InfoObject.GetXpath()

        $ConfigNode = 'kerberos'

        $ReturnObject = @()
        foreach ($entry in $Response.response.result.$ConfigNode.entry) {
            $NewEntry      = New-Object PaKerberosProfile
            $ReturnObject += $NewEntry

            $NewEntry.Vsys   = $Vsys
            $NewEntry.Device = $Device

            $NewEntry.Name         = $entry.name
            $NewEntry.Servers      = @()

            # bool values
            $BoolProperties = @{ 'AdminUseOnly' = 'admin-use-only' }

            foreach ($Bool in $BoolProperties.GetEnumerator()) {
                $PsProp  = $Bool.Name
                $XmlProp = $Bool.Value
                $NewEntry.$PsProp = $entry.$XmlProp
            }

            foreach ($Server in $entry.server.entry) {
                $NewServer         = New-Object PaAuthServer
                $NewServer.Name    = $Server.name
                $NewServer.Server  = $Server.host
                $NewServer.Port    = $Server.port
                $NewEntry.Servers += $NewServer
            }
        }
        return $ReturnObject
    } else {
        Throw "$VerbosePrefix Not Connected, please use Get-PaConfig to connect before using other cmdlets."
    }
}