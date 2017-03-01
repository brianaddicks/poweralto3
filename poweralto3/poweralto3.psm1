###############################################################################
## Powershell v5 Classes
###############################################################################


###############################################################################
# PaConfigObject
class PaConfigObject {
    # Generic Properties
    [string]$Vsys = 'shared'
    [string]$Device
    [string]$ConfigNode
    hidden [string]$ManualXml
    
    # BaseXPath
    [string] getBaseXPath() {
        $xPath += "/config"
        if ($this.Vsys -eq 'shared') {
            $xPath += '/shared/'
            $xPath += $this.ConfigNode
        } else {
            $xPath += "/devices/entry"
            
            # Add Device
            if ($this.Device) {
                $xPath += "[@name='$($this.Device)']"
            }
            
            # Add Vsys
            $xPath += "/vsys/entry"
            if ($this.Vsys) {
                $xPath += "[@name='$($this.Vsys)']"
            }

            $xPath += '/'
            $xPath += $this.ConfigNode
        }

        return $xPath
    }

    # XPath
    [string] getXPath() {
        return $this.getBaseXPath()
    }

    # Xml
    [System.Xml.Linq.XElement] getXml() {
        if ($this.ManualXml) {
            return [System.Xml.Linq.XElement]$this.ManualXml
        } else {
        # Document Root
        $doc = [System.Xml.Linq.XDocument]::new()

        # Create and add "entry" node
        $entry = [System.Xml.Linq.XElement]::new("entry",$null)

        return $doc.Element("entry")
        }
    }

    # Pretty XMl
    [string] PrintPrettyXml() {
        return $this.getXml().ToString()
    }

    # Plaintext Xml
    [string] PrintPlainXml() {
        return $this.getXml().ToString([System.Xml.Linq.SaveOptions]::DisableFormatting)
    }
}

###############################################################################
# HelperRegex
class HelperRegex {
    static [string]$Ipv4 = '\b((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b'
    static [string]$Fqdn = '(?=^.{1,254}$)(^(?:(?!\d|-)[a-zA-Z0-9\-]{1,63}(?<!-)\.?)+(?:[a-zA-Z]{2,})$)'

    # function for checking regular expressions
    static [string] checkRegex([string]$matchString, [string]$regexString, [string]$errorMessage) {
        $regex = [regex]$regexString
        if ($regex.Match($matchString).Success) {
            return $matchString
        } else {
            Throw $errorMessage
        }
    }

    static [bool] checkRegex([string]$matchString, [string]$regexString, [bool]$returnBool) {
        $regex = [regex]$regexString
        if ($regex.Match($matchString).Success) {
            return $true
        } else {
            return $false
        }
    }

    # Ipv4 Address
    static [string] isIpv4([string]$matchString, [string]$errorMessage) {
        $regexString  = [HelperRegex]::Ipv4
        return [HelperRegex]::checkRegex($matchString,$regexString,$errorMessage)
    }

    static [bool] isIpv4([string]$matchString,  [bool]$returnBool) {
        $regexString  = [HelperRegex]::Ipv4
        return [HelperRegex]::checkRegex($matchString,$regexString,$true)
    }

    # Fqdn
    static [string] isFqdn([string]$matchString, [string]$errorMessage) {
        $regexString  = [HelperRegex]::Fqdn
        return [HelperRegex]::checkRegex($matchString,$regexString,$errorMessage)
    }

    static [bool] isFqdn([string]$matchString,  [bool]$returnBool) {
        $regexString  = [HelperRegex]::Fqdn
        return [HelperRegex]::checkRegex($matchString,$regexString,$true)
    }

    # Fqdn or Ipv4 Address
    static [string] isFqdnOrIpv4([string]$matchString, [string]$errorMessage) {
        $regexString  = [HelperRegex]::Ipv4 + "|" + [HelperRegex]::Fqdn
        return [HelperRegex]::checkRegex($matchString,$regexString,$errorMessage)
    }

    static [bool] isFqdnOrIpv4([string]$matchString,  [bool]$returnBool) {
        $regexString  = [HelperRegex]::Ipv4 + "|" + [HelperRegex]::Fqdn
        return [HelperRegex]::checkRegex($matchString,$regexString,$true)
    }

    # Constructor
    HelperRegex () {
    }
}

###############################################################################
# HelperWeb
class HelperWeb {
    static [string] createQueryString ([hashtable]$hashTable) {
        $i = 0
        $queryString = "?"
        foreach ($hash in $hashTable.GetEnumerator()) {
            $i++
            $queryString += $hash.Name + "=" + $hash.Value
            if ($i -lt $HashTable.Count) {
                $queryString += "&"
            }
        }
        return $queryString
    }
}

###############################################################################
# HelperXml
class HelperXml {
    # Element without Members
    static [System.Xml.Linq.XElement] createXmlWithoutMembers([string]$propertyName, [string]$data) {
        if ($data) {
            return [System.Xml.Linq.XElement]::new($propertyName,$data)
        } else {
            return $null
        }
    }

    # Element with Members
    static [System.Xml.Linq.XElement] createXmlWithMembers([string]$propertyName, [array]$members, [bool] $isRequired) {
        $node = [System.Xml.Linq.XElement]::new($propertyName,$null)
        if ($members) {
            foreach ($member in $members) {
                $node.Add( [System.Xml.Linq.XElement]::new("member",$member) )
            }
        } else {
            if ($isRequired) {
                $node.Add( [System.Xml.Linq.XElement]::new("member","any") )
            } else {
                return $null
            }
        }
        return $node
    }
}

###############################################################################
# PaAddress
class PaAddress : PaConfigObject {
    [string]$Name
    [string]$Description
    [string]$Type
    [string]$Address
    [array]$Tags
    [string]$ConfigNode = "address"

    # XPath
    [string] getXPath() {
        $returnXPath = $this.getBaseXPath()

        # Add Name
        if ($this.Name) {
            $returnXPath += "/entry[@name='"
            $returnXPath += $this.Name
            $returnXPath += "']"
        }

        return $returnXPath
    }

    # Xml
    [System.Xml.Linq.XElement] getXml() {
        # Document Root
        $doc = [System.Xml.Linq.XDocument]::new()

        # Create and add "entry" node
        $entry = [System.Xml.Linq.XElement]::new("entry",$null)
        $entry.SetAttributeValue("name",$this.Name)
        $doc.Add($entry)

        # Add Name
        $doc.Element("entry").Add([HelperXml]::createXmlWithoutMembers($this.Type,$this.Address))

        # Add Description
        $doc.Element("entry").Add([HelperXml]::createXmlWithoutMembers("description",$this.Description))
        
        # Add Tags
        $doc.Element("entry").Add([HelperXml]::createXmlWithMembers("tag",$this.Tags,$false))

        return $doc.Element("entry")
    }
}

###############################################################################
# PaAdmin
class PaAdmin : PaConfigObject {
    [string]$Name
    [string]$AuthProfile
    [bool]$ClientCert
    [bool]$PublicKey
    [string]$AdminType
    [string]$AdminProfile
    [array]$VsysAccess
    [string]$PasswordProfile

    [string]$ConfigNode = "mgt-config/users"

    # BaseXPath
    [string] getBaseXPath() {
        $xPath = "/config"

        $xPath += $this.ConfigNode

        return $xPath
    }

    # XPath
    [string] getXPath() {
        $returnXPath = $this.getBaseXPath()

        # Add Name
        if ($this.Name) {
            $returnXPath += "/entry[@name='"
            $returnXPath += $this.Name
            $returnXPath += "']"
        }

        return $returnXPath
    }

    # Xml
    [System.Xml.Linq.XElement] getXml() {
        # Document Root
        $doc = [System.Xml.Linq.XDocument]::new()

        # Create and add "entry" node
        $entry = [System.Xml.Linq.XElement]::new("entry",$null)

        return $doc.Element("entry")
    }
}

###############################################################################
# PaAuthenticationProfile
class PaAuthenticationProfile : PaConfigObject {
    [string]$Name
    [string]$Type
    [string]$UserDomain
    [array]$AllowList
    [int]$FailedAttempts
    [int]$LockoutTime
    [string]$ServerProfile
    [string]$LoginAttribute
    [string]$PasswordExpiryWarning
    [string]$UsernameModifier
    [bool]$RetrieveGroup
    [string]$KerberosRealm

    [string]$ConfigNode = "authentication-profile"

    # XPath
    [string] getXPath() {
        $returnXPath = $this.getBaseXPath()

        # Add Name
        if ($this.Name) {
            $returnXPath += "/entry[@name='"
            $returnXPath += $this.Name
            $returnXPath += "']"
        }

        return $returnXPath
    }

    # Xml
    [System.Xml.Linq.XElement] getXml() {
        # Document Root
        $doc = [System.Xml.Linq.XDocument]::new()

        # Create and add "entry" node
        $entry = [System.Xml.Linq.XElement]::new("entry",$null)

        return $doc.Element("entry")
    }
}

###############################################################################
# PaAuthServer
class PaAuthServer {
    [string]$Name
    [string]$Server
    [string]$Port
}

###############################################################################
# PaDevice
class PaDevice {
    [ValidateRange(1,65535)]
    [int]$Port = 443
    
    [string]$ApiKey

    [ValidateSet('http','https')] 
    [string]$Protocol = "https"

    [string]$Name
    [string]$IpAddress
    [string]$Model
    [string]$Serial
    [string]$OsVersion
    [string]$GpAgent
    [string]$AppVersion
    [string]$ThreatVersion
    [string]$WildFireVersion
    [string]$UrlVersion

    # DeviceAddress
    hidden [string]$DeviceAddress

    setDeviceAddress([string]$deviceAddress) {
        $this.DeviceAddress = [HelperRegex]::isFqdnOrIpv4($deviceAddress,"DeviceAddress must be a valid FQDN or IPv4 Address.")
    }

    [string] getDeviceAddress() {
        $returnValue = [HelperRegex]::isFqdnOrIpv4($this.DeviceAddress,"DeviceAddress must be a valid FQDN or IPv4 Address.")
        return $returnValue
    }

    # Track usage
    hidden [bool]$Connected
    [array]$UrlHistory
    [array]$RawQueryResultHistory
    [array]$QueryHistory
    $LastError
    $LastResult

    # Error handling
    [bool] checkConnectionStatus([string]$errorPrefix) {
        if ($this.Connected) {
            return $true
        } else {
            throw "$errorPrefix Not Connected, please use Get-PaConfig to connect before using other cmdlets."
        }
    }

    # Function for created the base API Url
    [String] getApiUrl() {
        if ($this.DeviceAddress) {
            $url = $this.Protocol + "://" + $this.getDeviceAddress() + ":" + $this.Port + "/api/"
            return $url
        } else {
            return $null
        }
    }

    ############################################################################################
    # Api Query Functions

    # Base API Query
    [Xml] invokeApiQuery([hashtable]$queryString) {
        if ($queryString.type -ne "keygen") {
            $queryString.key = $this.ApiKey
        }
        $formattedQueryString = [HelperWeb]::createQueryString($queryString)
        $url = $this.getApiUrl() + $formattedQueryString
        if ($queryString.type -ne "keygen") {
            $this.UrlHistory += $url
            $this.QueryHistory += $queryString
        } else {
            $formattedQueryString = [HelperWeb]::createQueryString($queryString)
            $this.UrlHistory += $url.Replace($queryString.password,"PASSWORDREDACTED")
        }
        try {
            $rawResult = Invoke-WebRequest -Uri $url -SkipCertificateCheck
        } catch {
            Throw "$($error[0].ToString()) $($error[0].InvocationInfo.PositionMessage)"
        }
        $this.RawQueryResultHistory += $rawResult
        $result = [xml]($rawResult.Content)
        $this.LastResult = $result

        # Handle Errors
        if ($result.response.status -ne "success") {
            $errorMessage = "PaDevice: " + $result.response.status + " " + $result.response.code + ": "
            if ($result.response.msg.line) {
                if ($result.response.msg.line."#cdata-section") {
                    $errorMessage += "Too Many errors, check `$global:PaDeviceObject.LastError for more details."
                    $this.LastError = $result.response.msg.line."#cdata-section"
                } else {
                    $errorMessage += $result.response.msg.line
                    $this.LastError = $result.response.msg.line
                }
            } else {
                $errorMessage += $result.response.result.msg
                $this.LastError = $result.response.result.msg
            }
            Throw $errorMessage
        }

        return $result
    }

    # Config API Query
    [Xml] invokeConfigQuery([string]$xPath,[string]$action) {
        $queryString = @{}
        $queryString.type = "config"
        $queryString.action = $action
        $queryString.xpath = $xPath
        $result = $this.invokeApiQuery($queryString)
        return $result
    }

    [Xml] invokeConfigQuery([string]$xPath,[string]$action,[string]$element) {
        $queryString         = @{}
        $queryString.type    = "config"
        $queryString.action  = $action
        $queryString.xpath   = $xPath
        $queryString.element = $element

        $result = $this.invokeApiQuery($queryString)
        return $result
    }

    # Keygen API Query
    [xml] invokeKeygenQuery([string]$user,[string]$password) {
        $queryString = @{}
        $queryString.type = "keygen"
        $queryString.user = $user
        $queryString.password = $password
        $result = $this.invokeApiQuery($queryString)
        $this.ApiKey = $result.response.result.key
        return $result
    }

    # Keygen API Query
    [xml] invokeOperationalQuery([string]$cmd) {
        $queryString = @{}
        $queryString.type = "op"
        $queryString.cmd = $cmd
        $result = $this.invokeApiQuery($queryString)
        return $result
    }

    # Test Connection
    [bool] testConnection() {
        $result = $this.invokeOperationalQuery('<show><system><info></info></system></show>')
        $this.Connected       = $true
        $this.Name            = $result.response.result.system.devicename
        $this.IpAddress       = $result.response.result.system.'ip-address'
        $this.Model           = $result.response.result.system.model
        $this.Serial          = $result.response.result.system.serial
        $this.OsVersion       = $result.response.result.system.'sw-version'
        $this.GpAgent         = $result.response.result.system.'global-protect-client-package-version'
        $this.AppVersion      = $result.response.result.system.'app-version'
        $this.ThreatVersion   = $result.response.result.system.'threat-version'
        $this.WildFireVersion = $result.response.result.system.'wildfire-version'
        $this.UrlVersion      = $result.response.result.system.'url-filtering-version'
        return $true
    }
}

###############################################################################
# PaKerberosProfile
class PaKerberosProfile : PaConfigObject {
    [string]$Name
    [bool]$AdminUseOnly
    [array]$Servers

    [string]$ConfigNode = "server-profile/kerberos"

    # XPath
    [string] getXPath() {
        $returnXPath = $this.getBaseXPath()

        # Add Name
        if ($this.Name) {
            $returnXPath += "/entry[@name='"
            $returnXPath += $this.Name
            $returnXPath += "']"
        }

        return $returnXPath
    }

    # Xml
    [System.Xml.Linq.XElement] getXml() {
        # Document Root
        $doc = [System.Xml.Linq.XDocument]::new()

        # Create and add "entry" node
        $entry = [System.Xml.Linq.XElement]::new("entry",$null)

        return $doc.Element("entry")
    }
}

###############################################################################
# PaLdapProfile
class PaLdapProfile : PaConfigObject {
    [string]$Name
    [bool]$AdminUseOnly
    [string]$Type
    [string]$BaseDN
    [string]$BindDN
    
    [int]$BindTimeout
    [int]$SearchTimout
    [int]$RetryInterval
    
    [bool]$RequireSSL
    [bool]$VerifyServerCertificate

    [array]$Servers

    [string]$ConfigNode = "server-profile/ldap"

    # XPath
    [string] getXPath() {
        $returnXPath = $this.getBaseXPath()

        # Add Name
        if ($this.Name) {
            $returnXPath += "/entry[@name='"
            $returnXPath += $this.Name
            $returnXPath += "']"
        }

        return $returnXPath
    }

    # Xml
    [System.Xml.Linq.XElement] getXml() {
        # Document Root
        $doc = [System.Xml.Linq.XDocument]::new()

        # Create and add "entry" node
        $entry = [System.Xml.Linq.XElement]::new("entry",$null)

        return $doc.Element("entry")
    }
}

###############################################################################
# PaPasswordProfile
class PaPasswordProfile : PaConfigObject {
    [string]$Name
    [int]$ExpirationPeriod
    [int]$ExpirationWarningPeriod
    [int]$PostExpirationAdminLoginCount
    [int]$PostExpirationGracePeriod
    [string]$Vsys = 'shared'

    [string]$ConfigNode = "mgt-config/password-profile"

    # BaseXPath
    [string] getBaseXPath() {
        $xPath = "/config"

        $xPath += $this.ConfigNode

        return $xPath
    }

    # XPath
    [string] getXPath() {
        $returnXPath = $this.getBaseXPath()

        # Add Name
        if ($this.Name) {
            $returnXPath += "/entry[@name='"
            $returnXPath += $this.Name
            $returnXPath += "']"
        }

        return $returnXPath
    }

    # Xml
    [System.Xml.Linq.XElement] getXml() {
        # Document Root
        $doc = [System.Xml.Linq.XDocument]::new()

        # Create and add "entry" node
        $entry = [System.Xml.Linq.XElement]::new("entry",$null)

        return $doc.Element("entry")
    }
}

###############################################################################
# PaRadiusProfile
class PaRadiusProfile : PaConfigObject {
    [string]$Name
    [bool]$AdminUseOnly
    [int]$Timeout
    [int]$Retries
    [array]$Servers

    [string]$ConfigNode = "server-profile/radius"

    # XPath
    [string] getXPath() {
        $returnXPath = $this.getBaseXPath()

        # Add Name
        if ($this.Name) {
            $returnXPath += "/entry[@name='"
            $returnXPath += $this.Name
            $returnXPath += "']"
        }

        return $returnXPath
    }

    # Xml
    [System.Xml.Linq.XElement] getXml() {
        # Document Root
        $doc = [System.Xml.Linq.XDocument]::new()

        # Create and add "entry" node
        $entry = [System.Xml.Linq.XElement]::new("entry",$null)

        return $doc.Element("entry")
    }
}

###############################################################################
# PaSession
class PaSession {
    [double]$Id
    [string]$Vsys
    [string]$Application
    [string]$State
    [string]$Type
    [string]$Source
    [string]$SourcePort
    [string]$SourceZone
    [string]$SourceTranslatedIp
    [string]$SourceTranslatedPort
    [string]$Destination
    [string]$DestinationPort
    [string]$DestinationZone
    [string]$DestinationTranslatedIp
    [string]$DestinationTranslatedPort
    [string]$Protocol

    [datetime]$StartTime
}

###############################################################################
# PaTacacsProfile
class PaTacacsProfile : PaConfigObject {
    [string]$Name
    [bool]$AdminUseOnly
    [int]$Timeout
    [bool]$UseSingleConnection
    [array]$Servers

    [string]$ConfigNode = "server-profile/tacplus"

    # XPath
    [string] getXPath() {
        $returnXPath = $this.getBaseXPath()

        # Add Name
        if ($this.Name) {
            $returnXPath += "/entry[@name='"
            $returnXPath += $this.Name
            $returnXPath += "']"
        }

        return $returnXPath
    }

    # Xml
    [System.Xml.Linq.XElement] getXml() {
        # Document Root
        $doc = [System.Xml.Linq.XDocument]::new()

        # Create and add "entry" node
        $entry = [System.Xml.Linq.XElement]::new("entry",$null)

        return $doc.Element("entry")
    }
}

###############################################################################
## Start Powershell Cmdlets
###############################################################################


###############################################################################
# Get-PaAdmin
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

###############################################################################
# Get-PaAuthenticationProfile
function Get-PaAuthenticationProfile {
    [CmdletBinding()]
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

###############################################################################
# Get-PaConfig
function Get-PaConfig {
    [CmdletBinding()]
	Param (
        [Parameter(Mandatory=$False,Position=0)]
		[string]$XPath = "/config",

        [Parameter(Mandatory=$False,Position=3)]
        [ValidateSet("get","show")]
        [string]$Action = "show"
    )
    
    $VerbosePrefix = "Get-PaConfig:"

    if ($global:PaDeviceObject.Connected) {
        $Response = $global:PaDeviceObject.invokeConfigQuery($XPath,$Action)

        return $Response
    } else {
        Throw "$VerbosePrefix Not Connected, please use Get-PaDevice to connect before using other cmdlets."
    }
}

###############################################################################
# Get-PaDevice
function Get-PaDevice {
    [CmdletBinding()]
	<#
	.SYNOPSIS
		Establishes initial connection to Palo Alto API.
		
	.DESCRIPTION
		The Get-PaDevice cmdlet establishes and validates connection parameters to allow further communications to the Palo Alto API. The cmdlet needs at least two parameters:
		 - The device IP address or FQDN
		 - A valid API key or PSCredential object
		
		The cmdlet returns an object containing details of the connection, but this can be discarded or saved as desired; the returned object is not necessary to provide to further calls to the API.
	
	.EXAMPLE
		Get-PaDevice "pa.example.com" "LUFRPT1asdfPR2JtSDl5M2tjfdsaTktBeTkyaGZMTURasdfTTU9BZm89OGtKN0F"
		
		Connects to Palo Alto Device using the default port (443) over SSL (HTTPS) using an API Key
		
	.PARAMETER DeviceAddress
		Fully-qualified domain name for the Palo Alto Device. Don't include the protocol ("https://" or "http://").

    .PARAMETER ApiKey
		ApiKey used to access Palo Alto Device.
		
	.PARAMETER Credential
		PSCredental object to provide as an alternative to an API Key.
	
	.PARAMETER Port
		The port the Palo Alto Device is using for management communicatins. This defaults to port 443 over HTTPS, and port 80 over HTTP.
	
	.PARAMETER HttpOnly
		When specified, configures the API connection to run over HTTP rather than the default HTTPS. Not recommended!
	
    .PARAMETER SkipCertificateCheck
		When used, all certificate warnings are ignored.

    .PARAMETER Quiet
		When used, the cmdlet returns nothing on success.
    
	#>

	Param (
		[Parameter(Mandatory=$True,Position=0)]
		[ValidatePattern("\d+\.\d+\.\d+\.\d+|(\w\.)+\w")]
		[string]$DeviceAddress,

        [Parameter(ParameterSetName="keyonly",Mandatory=$True,Position=1)]
        [string]$ApiKey,

        [Parameter(ParameterSetName="credential",Mandatory=$True,Position=1)]
        [System.Management.Automation.CredentialAttribute()]$Credential,

		[Parameter(Mandatory=$False,Position=2)]
		[int]$Port = 443,

		[Parameter(Mandatory=$False)]
		[alias('http')]
		[switch]$HttpOnly,
        
		[Parameter(Mandatory=$False)]
		[switch]$SkipCertificateCheck,

        [Parameter(Mandatory=$False)]
		[alias('q')]
		[switch]$Quiet
	)

    BEGIN {
		$VerbosePrefix = "Get-PaDevice:"

		if ($HttpOnly) {
			$Protocol = "http"
			if (!$Port) { $Port = 80 }
		} else {
			$Protocol = "https"
			if (!$Port) { $Port = 443 }
			
			$global:PaDeviceObject = New-Object PaDevice
            $global:PaDeviceObject.SetDeviceAddress($DeviceAddress)
			$global:PaDeviceObject.Protocol = $Protocol
			$global:PaDeviceObject.Port     = $Port

            if ($ApiKey) {
                $global:PaDeviceObject.ApiKey = $ApiKey
            } else {
                $UserName = $Credential.UserName
                $Password = $Credential.getnetworkcredential().password
            }
		}
    }

    PROCESS {
        
        if (!($ApiKey)) {
            Write-Verbose "$VerbosePrefix Attempting to generate API Key."
            $global:PaDeviceObject.invokeKeygenQuery($UserName,$Password)
            Write-Verbose "$VerbosePrefix API Key successfully generated."
        }

        $TestConnection = $global:PaDeviceObject.testConnection()

        if (!($Quiet)) {
            return $global:PaDeviceObject
        }
    }
}

###############################################################################
# Get-PaKerberosProfile
function Get-PaKerberosProfile {
    [CmdletBinding()]
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

###############################################################################
# Get-PaLdapProfile
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

###############################################################################
# Get-PaPasswordProfile
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

###############################################################################
# Get-PaRadiusProfile
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

###############################################################################
# Get-PaSession
function Get-PaSession {
    [CmdletBinding()]
	Param (
		[Parameter(Mandatory=$False,ParameterSetName="id")]
		[int]$Id,

        [Parameter(Mandatory=$False,ParameterSetName="filter")]
		[string]$Application,

        [Parameter(Mandatory=$False,ParameterSetName="filter")]
		[string]$Destination,

        [Parameter(Mandatory=$False,ParameterSetName="filter")]
		[int]$DestinationPort,

        [Parameter(Mandatory=$False,ParameterSetName="filter")]
		[string]$DestinationUser,

        [Parameter(Mandatory=$False,ParameterSetName="filter")]
		[string]$EgressInterface,

        [Parameter(Mandatory=$False,ParameterSetName="filter")]
		[string]$HwInterface,

        [Parameter(Mandatory=$False,ParameterSetName="filter")]
		[string]$IngressInterface,

        [Parameter(Mandatory=$False,ParameterSetName="filter")]
		[string]$SourceZone,

        [Parameter(Mandatory=$False,ParameterSetName="filter")]
		[string]$DestinationZone,

        [Parameter(Mandatory=$False,ParameterSetName="filter")]
		[string]$MinKb,

        [Parameter(Mandatory=$False,ParameterSetName="filter")]
		[string]$Rule,

        [Parameter(Mandatory=$False,ParameterSetName="filter")]
		[string]$NatRule,

        [Parameter(Mandatory=$False,ParameterSetName="filter")]
		[string]$PbfRule,

        [Parameter(Mandatory=$False,ParameterSetName="filter")]
		[string]$QosRule,

        [Parameter(Mandatory=$False,ParameterSetName="filter")]
		[string]$QosClass,

        [Parameter(Mandatory=$False,ParameterSetName="filter")]
		[string]$QosNodeId,

        [Parameter(Mandatory=$False,ParameterSetName="filter")]
		[string]$Nat,

        [Parameter(Mandatory=$False,ParameterSetName="filter")]
		[string]$Rematch,

        [Parameter(Mandatory=$False,ParameterSetName="filter")]
		[string]$SslDecrypt,

        [Parameter(Mandatory=$False,ParameterSetName="filter")]
		[string]$Type,

        [Parameter(Mandatory=$False,ParameterSetName="filter")]
		[int]$Protocol,

        [Parameter(Mandatory=$False,ParameterSetName="filter")]
		[string]$Source,

        [Parameter(Mandatory=$False,ParameterSetName="filter")]
		[int]$SourcePort,

        [Parameter(Mandatory=$False,ParameterSetName="filter")]
		[string]$SourceUser,

        [Parameter(Mandatory=$False,ParameterSetName="filter")]
		[double]$StartAt,

        [Parameter(Mandatory=$False,ParameterSetName="filter")]
		[string]$State
    )

    $VerbosePrefix = "Get-PaSession:"

    $Filters = @{ "Application"      = "application"
                  "Destination"      = "destination"
                  "DestinationPort"  = "destination-port"
                  "DestinationUser"  = "destination-user"
                  "EgressInterface"  = "egress-interface"
                  "HwInterface"      = "hw-interface"
                  "IngressInterface" = "ingress-interface"
                  "SourceZone"       = "from"
                  "DestinationZone"  = "to"
                  "MinKb"            = "min-kb"
                  "Rule"             = "rule"
                  "NatRule"          = "nat-rule"
                  "PbfRule"          = "pbf-rule"
                  "QosRule"          = "qos-rule"
                  "QosClass"         = "qos-class"
                  "QosNodeId"        = "qos-node-id"
                  "Nat"              = "nat"
                  "Rematch"          = "rematch"
                  "SslDecrypt"       = "ssl-descrypt"
                  "Type"             = "type"
                  "Protocol"         = "protocol"
                  "Source"           = "source"
                  "SourcePort"       = "source-port"
                  "SourceUser"       = "source-user"
                  "StartAt"          = "start-at"
                  "State"            = "state" }

    $Command = "<show><session>"
    
    if ($Id) {
        $Command += "<id>$Id</id>"
    } else {
        $Command += "<all><filter>"
        foreach ($Filter in $Filters.GetEnumerator()) {
            try {
                $FilterValue = Get-Variable -Name $Filter.Name -ValueOnly
                if ($FilterValue) {
                    $Command += "<" + $Filter.Value + ">" + $FilterValue + "</" + $Filter.Value + ">"
                }
            } catch {}
        }
        $Command += "</filter></all>"
    }

    $Command += "</session></show>"
    Write-Verbose "$VerbosePrefix Command: $Command"

    $Results = Invoke-PaOperation $Command
    if ($Id) {
        $Results = $Results.response.result
    } else {
        $Results = $Results.response.result.entry
    }

    $ReturnResults = @()
    foreach ($Result in $Results) {
        $Session = New-Object PaSession

        if ($Id) {
            $Session.Id = $Id
        } else {
            $Session.Id = $Result.idx
        }

        $Session.Vsys        = $Result.vsys
        $Session.Application = $Result.application
        
        # Format Time
        $StartTime = $Result.'start-time' -replace ' ',''
        $Session.StartTime   = [datetime]::ParseExact($StartTime,"dddMMMdHH:mm:ssyyyy",$null)

        if ($Result.c2s) {
            $Session.State                     = $Result.c2s.state
            $Session.Type                      = $Result.c2s.type
            $Session.Source                    = $Result.c2s.source
            $Session.SourcePort                = $Result.c2s.sport
            $Session.SourceZone                = $Result.c2s.'source-zone'
            $Session.Destination               = $Result.c2s.dst
            $Session.DestinationPort           = $Result.c2s.dport
            $Session.Protocol                  = $Result.c2s.proto
            
            $Session.DestinationZone           = $Result.s2c.'source-zone'
            $Session.SourceTranslatedIp        = $Result.s2c.dst
            $Session.SourceTranslatedPort      = $Result.s2c.dport
            $Session.DestinationTranslatedIp   = $Result.s2c.source
            $Session.DestinationTranslatedPort = $Result.s2c.sport
        } else {
            $Session.State                     = $Result.state
            $Session.Type                      = $Result.type
            $Session.Source                    = $Result.source
            $Session.SourcePort                = $Result.sport
            $Session.SourceZone                = $Result.from
            $Session.SourceTranslatedIp        = $Result.xsource
            $Session.SourceTranslatedPort      = $Result.xsport
            $Session.Destination               = $Result.dst
            $Session.DestinationPort           = $Result.dport
            $Session.DestinationZone           = $Result.to
            $Session.DestinationTranslatedIp   = $Result.xdst
            $Session.DestinationTranslatedPort = $Result.xdport
            $Session.Protocol                  = $Result.proto
        }

        $ReturnResults += $Session 
    }

    return $ReturnResults
}

###############################################################################
# Get-PaTacacsProfile
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

###############################################################################
# Get-PaVsys
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

###############################################################################
# Invoke-PaOperation
function Invoke-PaOperation {
    [CmdletBinding()]
	Param (
		[Parameter(Mandatory=$False,Position=0)]
		[string]$Command
    )

    $VerbosePrefix = "Invoke-PaOperation:"

    $CheckConnection = $global:PaDeviceObject.checkConnectionStatus($VerbosePrefix)

    return $global:PaDeviceObject.invokeOperationalQuery($Command)
}

###############################################################################
# Invoke-PaSessionTracker
function Invoke-PaSessionTracker {
    [CmdletBinding()]
	Param (
        [Parameter(Mandatory=$False)]
		[int]$Interval = 5,

        [Parameter(Mandatory=$False)]
		[array]$ShowProperties = @("StartTime","Id","Application","Source","Destination","State","DestinationPort"),

        [Parameter(Mandatory=$False)]
		[int]$Count = 40,

        [Parameter(Mandatory=$False)]
		[string]$Application,

        [Parameter(Mandatory=$False)]
		[string]$Destination,

        [Parameter(Mandatory=$False)]
		[int]$DestinationPort,

        [Parameter(Mandatory=$False)]
		[string]$DestinationUser,

        [Parameter(Mandatory=$False)]
		[string]$EgressInterface,

        [Parameter(Mandatory=$False)]
		[string]$HwInterface,

        [Parameter(Mandatory=$False)]
		[string]$IngressInterface,

        [Parameter(Mandatory=$False)]
		[string]$SourceZone,

        [Parameter(Mandatory=$False)]
		[string]$DestinationZone,

        [Parameter(Mandatory=$False)]
		[string]$MinKb,

        [Parameter(Mandatory=$False)]
		[string]$Rule,

        [Parameter(Mandatory=$False)]
		[string]$NatRule,

        [Parameter(Mandatory=$False)]
		[string]$PbfRule,

        [Parameter(Mandatory=$False)]
		[string]$QosRule,

        [Parameter(Mandatory=$False)]
		[string]$QosClass,

        [Parameter(Mandatory=$False)]
		[string]$QosNodeId,

        [Parameter(Mandatory=$False)]
		[string]$Nat,

        [Parameter(Mandatory=$False)]
		[string]$Rematch,

        [Parameter(Mandatory=$False)]
		[string]$SslDecrypt,

        [Parameter(Mandatory=$False)]
		[string]$Type,

        [Parameter(Mandatory=$False)]
		[int]$Protocol,

        [Parameter(Mandatory=$False)]
		[string]$Source,

        [Parameter(Mandatory=$False)]
		[int]$SourcePort,

        [Parameter(Mandatory=$False)]
		[string]$SourceUser,

        [Parameter(Mandatory=$False)]
		[string]$State,

        [Parameter(Mandatory=$False)]
		[switch]$NoClear
    )

    $VerbosePrefix = "Invoke-PaSessionTracker:"
    
    $SessionParameters = $PSBOUNDPARAMETERS
    $SessionParameters.Remove("Interval") | Out-Null
    $SessionParameters.Remove("ShowProperties") | Out-Null
    $SessionParameters.Remove("NoClear") | Out-Null

    $StopWatch  = [System.Diagnostics.Stopwatch]::StartNew() # used by Write-Progress so it doesn't slow the whole function down

    # Header Function
    function WriteHeader([int]$TotalSessionsMatched,[int]$ShownSessions) {
        # Write top block of info.
        Write-Host "Total Sessions Matched: $TotalSessionsMatched"
        Write-Host "Sessions Shown: $ShownSessions"
        Write-Host ""
    }

    # GetColumnLengths
    function GetColumnLengths([array]$PropertiesDisplayed,[array]$Data) {
        $ColumnLengths = @()
        foreach ($Property in $PropertiesDisplayed) {
            $CurrentMaxLength = $Property.Length
            switch ($Property) {
                TickCount {
                    break
                }
                default {
                    foreach ($Datum in $Data) {
                        $CurrentLength = $Datum.$Property.ToString().Length
                        if ($CurrentLength -gt $CurrentMaxLength) {
                            $CurrentMaxLength = $CurrentLength
                        }
                    }
                }
            }

            # Create Object add to array
            $NewObject               = "" | Select-Object PropertyName,MaxLength
            $NewObject.PropertyName  = $Property
            $NewObject.MaxLength     = $CurrentMaxLength
            $ColumnLengths          += $NewObject
        }

        return $ColumnLengths
    }

    # WriteColumnHeaders
    function WriteColumnHeaders([array]$ColumnLengths) {
        # Selection
        Write-Host "  " -NoNewline
        # Count
        Write-Host "   " -NoNewline
        
        # Headers
        foreach ($Column in $ColumnLengths) {
            $ColumnLabel = $Column.PropertyName
            $Length      = $Column.MaxLength
            $ColumnLabel = $ColumnLabel.PadRight(($Length + 2)," ")
            
            Write-Host $ColumnLabel -NoNewline
        }
        Write-Host
    }



    While ($vkeycode -ne 81) {
        #$press = $host.ui.rawui.readkey("NoEcho,IncludeKeyDown")
        #$vkeycode = $press.virtualkeycode

        $OldSessions = $AllSessions | Select-Object *
        $Sessions = Get-PaSession @SessionParameters | Sort-Object StartTime
        $NewSessions = @()
        foreach ($Session in $Sessions[0..($Count-1)]) {
            $Lookup = $OldSessions | Where-Object { $_.Id -eq $Session.Id }
            if (!($Lookup)) {
                $NewSessions += $Session | Select-Object *,TickCount,Selected
            }
        }

        # Get proper number of OldSessions
        
        if (($NewSessions.Count -lt $Count) -and ($OldSessions.Count -gt 0)) {
            $AvailableCount = $Count - $NewSessions.Count
            $OldSessions = $OldSessions[0..($AvailableCount - 1)]
            $AllSessions = $NewSessions + $OldSessions
        } else {
            $AllSessions = $NewSessions
        }

        
        $AllSessions = $AllSessions | Select-Object * | Sort-Object StartTime -Descending
        $global:test3 = $AllSessions

        $LoopCount = 1
        while ($StopWatch.Elapsed.TotalMilliseconds -lt ($Interval * 1000)) {
                if (!($NoClear)) {
                    Clear-Host
                }

                # Write Header Block
                WriteHeader $Sessions.Count $AllSessions.Count
                
                #Extra Space for line counter
                Write-Host "     " -NoNewLine

                # Find Column Length and output Headers
                $LengthValues = @()
                foreach ($p in $ShowProperties) {

                    # Find length of header
                    if ($p -eq "TickCount") {
                        $ValueMaxLength = 0
                    } else {
                        $global:test = $Sessions

                        $ValueMaxLength = 0
                        foreach ($s in $AllSessions) {
                            $CurrentLength = $s.$p.ToString().Length
                            if ($CurrentLength -gt $ValueMaxLength) {
                                $ValueMaxLength = $CurrentLength
                            }
                        }
                    }
                    if ($p.Length -gt $ValueMaxLength) {
                        Write-Verbose "$VerbosePrefix CurrentValue: $ValueMaxLength; NameLength: $($p.Length)"
                        $ValueMaxLength = $p.Length
                    }

                    # Log Column Lengths
                    $New = "" | Select-Object Name,MaxLength
                    $New.Name = $p
                    if ($p -eq "StartTime") {
                        $New.MaxLength = ([string](Get-Date -Format "MM/dd/yy HH:mm:ss")).Length
                    } else {
                        $New.MaxLength = $ValueMaxLength
                    }
                    $LengthValues += $New
                    Write-Verbose "$VerbosePrefix Name: $($New.Name); MaxLength: $($New.MaxLength)"

                    # Write Headers
                    $Header = $p.PadRight(($ValueMaxLength + 2)," ")
                    Write-Host $Header -NoNewline
                }
                
                # Add NewLine after Headers
                Write-Host
            
                $SessionCounter = 0
                foreach ($Session in $AllSessions) {
                    if ($Session.TickCount -gt 0) {
                        $Session.TickCount++
                    } else {
                        $Session.TickCount = 1
                    }
                    
                    if ($Session.Selected) {
                        Write-Host "*" -NoNewline
                    } else {
                        Write-Host " " -NoNewline
                    }
                    
                    $SessionCounter++
                    $SessionCounterString = "$SessionCounter".PadRight(3," ")
                    Write-Host $SessionCounterString -NoNewline

                    $Lookup = $OldSessions | Where-Object { $_.Id -eq $Session.Id }
                    $ReverseLookup = $Sessions | Where-Object { $_.Id -eq $Session.Id }

                    foreach ($p in $LengthValues) {
                        $PropertyName = $p.Name
                        Write-Verbose "$VerbosePrefix PropertyName: $PropertyName"
                        $PropertyValue  = $Session.$PropertyName.ToString()
                        Write-Verbose "$VerbosePrefix PropertyValue: $PropertyValue"
                        $PropertyLength = $p.MaxLength
                        Write-Verbose "$VerbosePrefix PropertyLength: $PropertyLength"
                        $Value = [string]$PropertyValue.PadRight(($PropertyLength + 2)," ")

                        $WriteHostParams = @{}
                        $WriteHostParams.NoNewLine = $true

                        # Format Date, I suspect there's a better way to handle this
                        if ($PropertyName -eq "StartTime") {
                            $WriteHostParams.Object = ([string](Get-Date -Date $Value -Format "MM/dd/yy HH:mm:ss")).PadRight(($PropertyLength + 2)," ")
                        } else {
                            $WriteHostParams.Object = $Value
                        }

                        if (($ReverseLookup) -and (!($Lookup))) {
                            # New Session
                            $WriteHostParams.ForegroundColor = "DarkBlue"
                            switch ($PropertyName) {
                                "State" {
                                    switch ($Value) {
                                        {$_ -match "active"} {
                                            $WriteHostParams.ForegroundColor = "DarkGreen"
                                        }
                                        {$_ -match "discard"} {
                                            $WriteHostParams.ForegroundColor = "DarkRed"
                                        }
                                        default {
                                            # Don't change anything (yet)
                                        }
                                    }
                                    break
                                }
                            }
                        } elseif (($Lookup) -and (!($ReverseLookup))) {
                            # Inactive Session
                            $WriteHostParams.ForegroundColor = "DarkGray"
                        }
                        Write-Host @WriteHostParams
                    }
                    Write-Host
                }

                # Write blank lines
                $BlankLines = $Count - $AllSessions.Count
                for ($b = 0;$b -lt $BlankLines;$b++) {
                    Write-Host
                }

            #Start-Sleep $Interval
            # Show Progress Bar between API Calls
<#
            if ($StopWatch.Elapsed.TotalMilliseconds -ge ($LoopCount * 1000)) {
                $LoopCount++
                $PercentComplete = [math]::truncate($LoopCount / $Interval * 100)
                Write-Progress -Activity "Waiting to refresh sessions: $($Interval - $LoopCount)..." -PercentComplete $PercentComplete
                if ($StopWatch.Elapsed.TotalMilliseconds -ge ($Interval * 1000)) {
                    $StopWatch.Reset()
                    $StopWatch.Start()
                    $LoopCount = 1
                    Write-Progress -Activity "Refreshing..." -PercentComplete 100 -Completed
                }
            }#>
<#
            for ($p = 0;$p -lt $Interval;$p++) {
                $PercentComplete = ($p / $Interval) * 100
                $Activity = "Waiting to refresh sessions: $($Interval - $p)..."
                Write-Progress -Activity $Activity -PercentComplete $PercentComplete
                Start-Sleep 1
            }
            Write-Progress -Activity "Refreshing..." -PercentComplete 100#>
            
        }
    }
}

###############################################################################
# Set-PaConfig
function Set-PaConfig {
    [CmdletBinding()]
	Param (
		[Parameter(Mandatory=$True,Position=0,ParameterSetName="manual")]
		[string]$Xpath = "/config",

        [Parameter(Mandatory=$True,Position=1,ParameterSetName="manual")]
		[string]$ElementAsString,

        [Parameter(Mandatory=$True,Position=1,ParameterSetName="object",ValueFromPipeline=$true)]
		$PaObject
    )
    
    $VerbosePrefix = "Set-PaConfig:"

    if ($global:PaDeviceObject.Connected) {
        if ($PaObject) {
            Write-Verbose "$VerbosePrefix Getting info from Object"

            $ElementAsString = $PaObject.PrintPlainXml()
            $Xpath           = $PaObject.getXPath()
            
            Write-Verbose "$VerbosePrefix Element: $ElementAsString"
            Write-Verbose "$VerbosePrefix Xpath: $Xpath"
        }
        return $global:PaDeviceObject.invokeConfigQuery($Xpath,"set",$ElementAsString)
    } else {
        Throw "$VerbosePrefix Not Connected, please use Get-PaConfig to connect before using other cmdlets."
    }
}


