if ($PSVersionTable.PSVersion.Major -lt 6) {
    [Reflection.Assembly]::LoadWithPartialName("System.Xml.Linq")
    
}