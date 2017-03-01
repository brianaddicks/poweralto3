[CmdletBinding()]
Param (
    [Parameter(Mandatory=$False,Position=0)]
    [string]$Destination
)

$ModuleName = 'PowerAlto3'

if ($Destination) {
    $ResolvedPath = Resolve-Path $Destination
    if (Test-Path $ResolvedPath) {
        $DesiredPath = $ResolvedPath
    } else {
        Throw "Invalid Path Specified."
    }
} else {
    if (Test-Path env:\PSMODULEPATH) {
        $ModulePath = $env:PSMODULEPATH
        if ($ModulePath -match ";") {
            # Windows System
            $SplitChar = ";"
        } else {
            $SplitChar = ":"
        }
        $Split = $ModulePath -split $SplitChar
        $DesiredPath = $Split | ? { $_ -match "User" }
    } else {
        $DesiredPath = Join-Path -Path (Get-Location) -ChildPath $ModuleName
    }
}

# Create Directory
$CreateDirectory = New-Item (Join-Path -Path $DesiredPath -ChildPath $ModuleName) -ItemType Container
$OutputDirectory = Join-Path -Path $DesiredPath -ChildPath $ModuleName

$Files = @("poweralto3.psd1","poweralto3.psm1")

foreach ($File in $Files) {
    $Url = "https://raw.githubusercontent.com/brianaddicks/poweralto3/master/poweralto3/$File"    
    $OutputPath = Join-Path -Path $OutputDirectory -ChildPath $File
    Invoke-WebRequest -Uri $Url -OutFile $OutputPath
}