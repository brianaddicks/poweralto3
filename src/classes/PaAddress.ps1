class PaAddress {
    [string]$Name
    [bool]$Shared
    [string]$Description
    [string]$Type
    [string]$Address
    [array]$Tags
    [string]$Vsys = "vsys1"
    
    # XPath
    [string] getXPath() {
        $xPath = "/config/devices/entry/vsys/entry[@name='$($this.Vsys)']/address"
        return $xPath
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

    # Pretty XMl
    [string] PrintPrettyXml() {
        return $this.getXml().ToString()
    }

    # Plaintext Xml
    [string] PrintPlainXml() {
        return $this.getXml().ToString([System.Xml.Linq.SaveOptions]::DisableFormatting)
    }
}