class PaAddress : PaConfigObject {
    [string]$Name
    [string]$Description
    [string]$Type
    [string]$Address
    [array]$Tags
    [string]$ConfigNode = "/address"

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