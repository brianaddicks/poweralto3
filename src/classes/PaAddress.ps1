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
        $doc = [System.Xml.Linq.XDocument]::new()

        $entry = [System.Xml.Linq.XElement]::new("entry",$null)
        $entry.SetAttributeValue("name",$this.Name)

        $doc.Element("entry").Add($this.createXmlWithoutMembers($this.Type,$this.Address))

        $doc.Add($entry)

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
    <#
    private XElement createXmlWithMembers( string XmlKeyword, List<string> RuleProperty = null, bool Required = false) {
        XElement nodeXml = new XElement(XmlKeyword);
        if (RuleProperty != null) {
            foreach (string member in RuleProperty) {
                nodeXml.Add(
                    new XElement("member",member)
                );
            }
        } else {
            if (!(Required)) {
                return null;
            }
            nodeXml.Add(
                new XElement("member","any")
            );
        }
        return nodeXml;
    }

    #>

    # Element without Members
    [System.Xml.Linq.XElement] createXmlWithoutMembers([string]$propertyName, [string]$data) {
        if ($data) {
            return [System.Xml.Linq.XElement]::new($propertyName,$data)
        } else {
            return $null
        }
    }

    # Element with Members
    [System.Xml.Linq.XElement] createXmlWithoutMembers([string]$propertyName, [array]$data, [bool] $isRequired) {
        if ($data) {
            return [System.Xml.Linq.XElement]::new($propertyName,$data)
        } else {
            return $null
        }
    }

}