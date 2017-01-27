foreach ($class in (Get-ChildItem ./src/classes)) {
    . $class.FullName
}

foreach ($cmdlet in (Get-ChildItem ./src/cmdlets)) {
    . $cmdlet.FullName
}