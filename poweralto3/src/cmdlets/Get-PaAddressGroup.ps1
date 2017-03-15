function Get-PaAddressGroup {
    <#
	.SYNOPSIS
		Retrieves Address Group objects for a Palo Alto Device.
		
	.DESCRIPTION
        Retrieves Address Group objects for a Palo Alto Device.

	.EXAMPLE
		Get-PaAddressGroup
		
		Returns all Address Groups for all Vsys/Devices configured.

	.EXAMPLE
		Get-PaAddressGroup -Name "myaddress"

		Returns all Address Groups named "myaddress" for all Vsys/Devices configured.

    .EXAMPLE
		Get-PaAddressGroup -Name "myaddress" -Vsys "vsys1"

		Returns Address Group named "myaddress" configured on "vsys1".

	.PARAMETER Name
		Name of desired Address Group account to query.

    .PARAMETER Vsys
		Specifies the Vsys to query for configured Address Groups.
		
	.PARAMETER Device
		Specifies the Device to query for configured Address Groups (Panorama).
	
	#>
    [CmdletBinding()]
	Param (
		[Parameter(Mandatory=$False,Position=0)]
		[string]$Name,

        [Parameter(Mandatory=$False,Position=1)]
		[string]$Vsys,

        [Parameter(Mandatory=$False,Position=2)]
		[string]$Device
    )
    $VerbosePrefix = "Get-PaAddressGroup:"

    # todo
    # Would like to add -ResolveDynamicGroups to get the members of dynamic groups

    if ($global:PaDeviceObject.Connected) {
        $InfoObject        = New-Object PaAddressGroup
        $InfoObject.Name   = $Name
        $InfoObject.Vsys   = $Vsys
        $InfoObject.Device = $Device
        $Response          = Get-PaConfig $InfoObject.GetXpath()

        $ConfigNode = $InfoObject.ConfigNode

        $ReturnObject = @()

        $global:test = $PSBoundParameters

        if (!($Vsys)) {
            $global:vsys = Get-PaVsys
            foreach ($currentVsys in (Get-PaVsys)) {
                Write-Verbose "$VerbosePrefix Getting Addresses for Vsys: $currentVsys"
                $Params = $PSBoundParameters
                $Params.Vsys = $currentVsys
                $ReturnObject += Get-PaAddressGroup @Params
            }
        } else {
            # Check for singleton entries
            if ($Response.response.result.$ConfigNode) {
                $Entries = $Response.response.result.$ConfigNode.entry
            } else {
                $Entries = $Response.response.result.entry
            }

            # loop through entries
            foreach ($entry in $Entries) {
                $NewEntry      = New-Object PaAddressGroup
                $ReturnObject += $NewEntry

                $NewEntry.Vsys        = $Vsys
                $NewEntry.Device      = $Device
                $NewEntry.Description = $entry.description
                $NewEntry.Name        = $entry.name

                # tags
                foreach ($tag in $entry.tag.member) {
                    $NewEntry.Tags += $tag
                }

                # dynamic
                if ($entry.dynamic) {
                    $NewEntry.Filter = $entry.dynamic.filter
                    $NewEntry.Type = 'dynamic'
                }

                # static
                if ($entry.static) {
                    $NewEntry.Members = $entry.static.member
                    $NewEntry.Type = 'static'
                }
            }
        }
        return $ReturnObject
    } else {
        Throw "$VerbosePrefix Not Connected, please use Get-PaConfig to connect before using other cmdlets."
    }
}