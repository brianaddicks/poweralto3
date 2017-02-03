class PaConfigObject {
    # Generic Properties
    [string]$Vsys = "vsys1"
    hidden [string]$XPathNode
    hidden [string]$ManualXml
    
    # XPath
    [string] getXPath() {
        $xPath = "/config/devices/entry/vsys/entry[@name='$($this.Vsys)']/$($this.XPathNode)"
        return $xPath
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