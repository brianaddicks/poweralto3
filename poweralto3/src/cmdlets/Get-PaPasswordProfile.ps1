function Get-PaPasswordProfile {
    [CmdletBinding()]
	Param (
		[Parameter(Mandatory=$False,Position=0)]
		[string]$Name,

        [Parameter(Mandatory=$False,Position=1)]
		[string]$Vsys,

        [Parameter(Mandatory=$False,Position=2)]
		[string]$Device
    )
    
    $VerbosePrefix = "Get-PaPasswordProfile:"

    if ($global:PaDeviceObject.Connected) {
        $InfoObject        = New-Object PaPasswordProfile
        $InfoObject.Name   = $Name
        $InfoObject.Vsys   = $Vsys
        $InfoObject.Device = $Device
        $Response          = Get-PaConfig $InfoObject.GetXpath()

        $ConfigNode = $InfoObject.ConfigNode -replace 'mgt-config/'

        $ReturnObject = @()
        foreach ($entry in $Response.response.result.$ConfigNode.entry) {
            $NewEntry      = New-Object PaPasswordProfile
            $ReturnObject += $NewEntry

            $NewEntry.Vsys   = $Vsys
            $NewEntry.Device = $Device
            
            # Regular Properties
            $NewEntry.Name                          = $entry.name
            $NewEntry.ExpirationPeriod              = $entry.'password-change'.'expiration-period'
            $NewEntry.ExpirationWarningPeriod       = $entry.'password-change'.'expiration-warning-period'
            $NewEntry.PostExpirationAdminLoginCount = $entry.'password-change'.'post-expiration-admin-login-count'
            $NewEntry.PostExpirationGracePeriod     = $entry.'password-change'.'post-expiration-grace-period'
        }

        return $ReturnObject
    } else {
        Throw "$VerbosePrefix Not Connected, please use Get-PaConfig to connect before using other cmdlets."
    }
}