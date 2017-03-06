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