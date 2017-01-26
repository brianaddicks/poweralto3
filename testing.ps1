foreach ($class in (Get-ChildItem ./src/classes)) {
    . $class.FullName
}