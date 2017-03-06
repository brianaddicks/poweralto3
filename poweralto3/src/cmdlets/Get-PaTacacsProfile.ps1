function Get-PaTacacsProfile {
    [CmdletBinding()]
	Param (
		[Parameter(Mandatory=$False,Position=0)]
		[string]$Name,

        [Parameter(Mandatory=$False,Position=1)]
		[string]$Vsys = "shared",

        [Parameter(Mandatory=$False,Position=2)]
		[string]$Device
    )
    
    $VerbosePrefix = "Get-PaTacacsProfile:"

    if ($global:PaDeviceObject.Connected) {
        $InfoObject        = New-Object PaTacacsProfile
        $InfoObject.Name   = $Name
        $InfoObject.Vsys   = $Vsys
        $InfoObject.Device = $Device
        $Response          = Get-PaConfig $InfoObject.GetXpath()

        $ConfigNode = 'tacplus'

        $ReturnObject = @()
        foreach ($entry in $Response.response.result.$ConfigNode.entry) {
            $NewEntry      = New-Object PaTacacsProfile
            $ReturnObject += $NewEntry

            $NewEntry.Vsys   = $Vsys
            $NewEntry.Device = $Device

            $NewEntry.Name                = $entry.name
            $NewEntry.Timeout             = $entry.timeout
            $NewEntry.AdminUseOnly        = $entry.'admin-use-only'
            $NewEntry.UseSingleConnection = $entry.'use-single-connection'
            $NewEntry.Servers             = @()

            foreach ($Server in $entry.server.entry) {
                $NewServer         = New-Object PaAuthServer
                $NewServer.Name    = $Server.name
                $NewServer.Server  = $Server.address
                $NewServer.Port    = $Server.port
                $NewEntry.Servers += $NewServer
            }
        }
        return $ReturnObject
    } else {
        Throw "$VerbosePrefix Not Connected, please use Get-PaConfig to connect before using other cmdlets."
    }
}