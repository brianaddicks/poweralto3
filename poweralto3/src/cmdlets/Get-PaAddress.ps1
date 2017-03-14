function Get-PaAddress {
    [CmdletBinding()]
	Param (
		[Parameter(Mandatory=$False,Position=0)]
		[string]$Name,

        [Parameter(Mandatory=$False,Position=1)]
		[string]$Vsys,

        [Parameter(Mandatory=$False,Position=2)]
		[string]$Device
    )
    
    $VerbosePrefix = "Get-PaAddress:"

    if ($global:PaDeviceObject.Connected) {
        $InfoObject        = New-Object PaAddress
        $InfoObject.Name   = $Name
        $InfoObject.Vsys   = $Vsys
        $InfoObject.Device = $Device
        $Response          = Get-PaConfig $InfoObject.GetXpath()

        $ConfigNode = $InfoObject.ConfigNode

        $ReturnObject = @()

        if (!($Vsys)) {
            $global:vsys = Get-PaVsys
            foreach ($currentVsys in (Get-PaVsys)) {
                Write-Verbose "$VerbosePrefix Getting Addresses for Vsys: $currentVsys"
                $ReturnObject += Get-PaAddress -Vsys $currentVsys
            }
        } else {
            foreach ($entry in $Response.response.result.$ConfigNode.entry) {
                $NewEntry      = New-Object PaAddress
                $ReturnObject += $NewEntry

                $NewEntry.Vsys        = $Vsys
                $NewEntry.Device      = $Device
                $NewEntry.Description = $entry.description
                

                # ip-netmask
                if ($entry.'ip-netmask') {
                    $NewEntry.Address = $entry.'ip-netmask'
                    $NewEntry.Type    = 'ip-netmask'
                }

                # ip-range
                if ($entry.'ip-range') {
                    $NewEntry.Address = $entry.'ip-range'
                    $NewEntry.Type    = 'ip-range'
                }

                # fqdn
                if ($entry.fqdn) {
                    $NewEntry.Address = $entry.fqdn
                    $NewEntry.Type    = 'fqdn'
                }

                # tags
                foreach ($tag in $entry.tag.member) {
                    $NewEntry.Tags += $tag
                }

                $NewEntry.Name                    = $entry.name
            }
        }
        return $ReturnObject
    } else {
        Throw "$VerbosePrefix Not Connected, please use Get-PaConfig to connect before using other cmdlets."
    }
}