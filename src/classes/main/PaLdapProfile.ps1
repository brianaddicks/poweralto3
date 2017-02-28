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