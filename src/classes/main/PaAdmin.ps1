class PaAdmin : PaConfigObject {
    [string]$Name
    [string]$AuthProfile
    [bool]$ClientCert
    [bool]$PublicKey
    [string]$AdminType
    [string]$AdminProfile
    [array]$Vsys
    [string]$PasswordProfile

    [string]$ConfigNode = "/mgt-config/users"

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