foreach ($class in (Get-ChildItem ./src/classes)) {
    . $class.FullName
}

foreach ($cmdlet in (Get-ChildItem ./src/cmdlets)) {
    . $cmdlet.FullName
}

$address = new-object PaAddress
$address.Name = "MyAddress"
$address.Type = "ip-netmask"
$address.Address = "10.10.10.10"
$address.Description = "my description"
$address.tags = "tag1","tag2"