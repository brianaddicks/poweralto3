class HelperXml {
    # Element without Members
    static [System.Xml.Linq.XElement] createXmlWithoutMembers([string]$propertyName, [string]$data) {
        if ($data) {
            return [System.Xml.Linq.XElement]::new($propertyName,$data)
        } else {
            return $null
        }
    }

    # Element with Members
    static [System.Xml.Linq.XElement] createXmlWithMembers([string]$propertyName, [array]$members, [bool] $isRequired) {
        $node = [System.Xml.Linq.XElement]::new($propertyName,$null)
        if ($members) {
            foreach ($member in $members) {
                $node.Add( [System.Xml.Linq.XElement]::new("member",$member) )
            }
        } else {
            if ($isRequired) {
                $node.Add( [System.Xml.Linq.XElement]::new("member","any") )
            } else {
                return $null
            }
        }
        return $node
    }
}