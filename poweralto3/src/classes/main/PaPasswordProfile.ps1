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