function Get-PaLdapProfile {
    [CmdletBinding()]
	Param (
		[Parameter(Mandatory=$False,Position=0)]
		[string]$Name,

        [Parameter(Mandatory=$False,Position=1)]
		[string]$Vsys = "shared",

        [Parameter(Mandatory=$False,Position=2)]
		[string]$Device
    )
    
    $VerbosePrefix = "Get-PaLdapProfile:"

    if ($global:PaDeviceObject.Connected) {
        $InfoObject        = New-Object PaLdapProfile
        $InfoObject.Name   = $Name
        $InfoObject.Vsys   = $Vsys
        $InfoObject.Device = $Device
        $Response          = Get-PaConfig $InfoObject.GetXpath()

        $ConfigNode = 'ldap'

        $ReturnObject = @()
        foreach ($entry in $Response.response.result.$ConfigNode.entry) {
            $NewEntry      = New-Object PaLdapProfile
            $ReturnObject += $NewEntry

            $NewEntry.Vsys   = $Vsys
            $NewEntry.Device = $Device

            $NewEntry.Name                    = $entry.name
            $NewEntry.Type                    = $entry.'ldap-type'
            $NewEntry.BaseDN                  = $entry.base
            $NewEntry.BindDN                  = $entry.'bind-dn'
            $NewEntry.BindTimeout             = $entry.'bind-timelimit'
            $NewEntry.SearchTimout            = $entry.'timelimit'
            $NewEntry.RetryInterval           = $entry.'retry-interval'
            $NewEntry.Servers                 = @()

            # bool values
            $BoolProperties = @{ 'AdminUseOnly'            = 'admin-use-only'
                                 'RequireSSL'              = 'ssl'
                                 'VerifyServerCertificate' = 'verify-server-certificate' }

            foreach ($Bool in $BoolProperties.GetEnumerator()) {
                $PsProp  = $Bool.Name
                $XmlProp = $Bool.Value
                $NewEntry.$PsProp = $entry.$XmlProp
            }

            foreach ($Server in $entry.server.entry) {
                $NewServer         = New-Object PaAuthServer
                $NewServer.Name    = $Server.name
                $NewServer.Server  = $Server.address
                
                # port will be empty if it's the default (389)
                if ($Server.port) {
                    $NewServer.Port    = $Server.port
                } else {
                    $NewServer.Port = 389
                }

                $NewEntry.Servers += $NewServer
            }
        }
        return $ReturnObject
    } else {
        Throw "$VerbosePrefix Not Connected, please use Get-PaConfig to connect before using other cmdlets."
    }
}