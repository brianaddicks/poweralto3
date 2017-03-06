function Get-PaAdmin {
    [CmdletBinding()]
	Param (
		[Parameter(Mandatory=$False,Position=0)]
		[string]$Name,

        [Parameter(Mandatory=$False,Position=1)]
		[string]$Vsys,

        [Parameter(Mandatory=$False,Position=2)]
		[string]$Device
    )
    
    $VerbosePrefix = "Get-PaAdmin:"

    if ($global:PaDeviceObject.Connected) {
        $InfoObject        = New-Object PaAdmin
        $InfoObject.Name   = $Name
        $InfoObject.Vsys   = $Vsys
        $InfoObject.Device = $Device
        $Response          = Get-PaConfig $InfoObject.GetXpath()

        $ReturnObject = @()
        foreach ($entry in $Response.response.result.users.entry) {
            $NewEntry      = New-Object PaAdmin
            $ReturnObject += $NewEntry

            $NewEntry.Vsys   = $Vsys
            $NewEntry.Device = $Device
            
            # Regular Properties
            $NewEntry.Name            = $entry.name
            $NewEntry.AuthProfile     = $entry.'authentication-profile'
            $NewEntry.VsysAccess      = $entry.permissions.'role-based'.vsysadmin.entry.vsys.member
            $NewEntry.PasswordProfile = $entry.'password-profile'

            # Client Certificate
            if ($entry.'client-certificate-only' -eq 'yes') {
                $NewEntry.ClientCert = $true
            }
            
            # Public Key
            if ($entry.'public-key') {
                $NewEntry.PublicKey = $true
            }

            # AdminProfile
            if ($entry.permissions.'role-based'.custom) {
                $NewEntry.AdminType    = "RoleBased"
                $NewEntry.AdminProfile = $entry.permissions.'role-based'.custom.profile
            } else {
                $NewEntry.AdminType    = "Dynamic"
                $NewEntry.AdminProfile = ($entry.permissions.'role-based' | Get-Member -MemberType Property)[0].Name
            }
        }

        return $ReturnObject
    } else {
        Throw "$VerbosePrefix Not Connected, please use Get-PaConfig to connect before using other cmdlets."
    }
}