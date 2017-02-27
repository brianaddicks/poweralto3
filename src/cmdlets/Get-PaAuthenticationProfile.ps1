function Get-PaAuthenticationProfile {
	Param (
		[Parameter(Mandatory=$False,Position=0)]
		[string]$Name,

        [Parameter(Mandatory=$False,Position=1)]
		[string]$Vsys = "shared",

        [Parameter(Mandatory=$False,Position=2)]
		[string]$Device
    )
    
    $VerbosePrefix = "Get-PaAuthenticationProfile:"

    if ($global:PaDeviceObject.Connected) {
        $InfoObject        = New-Object PaAuthenticationProfile
        $InfoObject.Name   = $Name
        $InfoObject.Vsys   = $Vsys
        $InfoObject.Device = $Device
        $Response          = Get-PaConfig $InfoObject.GetXpath()

        $ConfigNode = $InfoObject.ConfigNode

        $ReturnObject = @()
        foreach ($entry in $Response.response.result.$ConfigNode.entry) {
            $NewEntry      = New-Object PaAuthenticationProfile
            $ReturnObject += $NewEntry

            $NewEntry.Vsys   = $Vsys
            $NewEntry.Device = $Device

            $NewEntry.Name             = $entry.name
            $NewEntry.Type             = ($entry.method | Get-Member -MemberType Property)[0].Name
            $NewEntry.UserDomain       = $entry.'user-domain'
            $NewEntry.UsernameModifier = $entry.'username-modifier'
            $NewEntry.AllowList        = $entry.'allow-list'.member
            $NewEntry.FailedAttempts   = $entry.lockout.'failed-attempts'
            $NewEntry.LockoutTime      = $entry.lockout.'lockout-time'

            $NewEntry.ServerProfile         = $entry.method."$($NewEntry.Type)".'server-profile'

            switch ($NewEntry.Type) {
                "ldap" {
                    $NewEntry.LoginAttribute        = $entry.method.ldap.'login-attribute'
                    $NewEntry.PasswordExpiryWarning = $entry.method.ldap.'passwd-exp-days'
                    break
                }
                "radius" {
                    if ($entry.method.radius.checkgroup -eq 'yes') {
                        $NewEntry.RetrieveGroup = $true
                    }
                    break
                }
                "kerberos" {
                    $NewEntry.KerberosRealm = $entry.method.kerberos.realm
                    break
                }
            }
        }
        return $ReturnObject
    } else {
        Throw "$VerbosePrefix Not Connected, please use Get-PaConfig to connect before using other cmdlets."
    }
}