class PaAddress {
    [string]$Name
    [bool]$Shared
    [string]$Description
    [string]$Type
    [string]$Address
    [array]$Tags
    [string]$Vsys
    
    # XPath

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
        <#
            XDocument XmlObject = new XDocument();
            
            // create entry nod and define name attribute
			XElement xmlEntry = new XElement("entry");
			xmlEntry.SetAttributeValue("name",this.Name);
			XmlObject.Add(xmlEntry);

			XmlObject.Element("entry").Add( createXmlWithoutMembers( this.addressType, this.address));	// Address
            XmlObject.Element("entry").Add( createXmlWithMembers( "tag", this.Tags, false ));			      // Tags
			XmlObject.Element("entry").Add( createXmlWithoutMembers( "description", this.Description));	// Description
			

			return XmlObject.Element("entry");
	  }#>
    }
    
}