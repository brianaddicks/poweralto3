class PaConfigObject {
    # Xml
    [System.Xml.Linq.XElement] getXml() {
        # Document Root
        $doc = [System.Xml.Linq.XDocument]::new()

        # Create and add "entry" node
        $entry = [System.Xml.Linq.XElement]::new("entry",$null)

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