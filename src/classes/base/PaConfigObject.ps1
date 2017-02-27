class PaConfigObject {
    # Generic Properties
    [string]$Vsys = 'shared'
    [string]$Device
    [string]$ConfigNode
    hidden [string]$ManualXml
    
    # BaseXPath
    [string] getBaseXPath() {
        $xPath += "/config"
        if ($this.Vsys -eq 'shared') {
            $xPath += '/shared/'
            $xPath += $this.ConfigNode
        } else {
            $xPath += "/devices/entry"
            
            # Add Device
            if ($this.Device) {
                $xPath += "[@name='$($this.Device)']"
            }
            
            # Add Vsys
            $xPath += "/vsys/entry"
            if ($this.Vsys) {
                $xPath += "[@name='$($this.Vsys)']"
            }

            $xPath += '/'
            $xPath += $this.ConfigNode
        }

        return $xPath
    }

    # XPath
    [string] getXPath() {
        return $this.getBaseXPath()
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