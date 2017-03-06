[CmdletBinding()]
Param (
    [Parameter(Mandatory=$False)]
    [string]$ReleaseNotes,

    [Parameter(Mandatory=$False)]
    [switch]$IncrementVersion
)

###############################################################################
# Create Manifest

# PsGallery requires: module name, version, description, and author

$Description = "@
PowerAlto provides an interface to the Palo Alto Firewall API.

https://github.com/brianaddicks/poweralto3
@"

if (Test-Path $ManifestFile) {
    $UpdateParams = @{}
    $UpdateParams.Path = $ManifestFile

    if ($ReleaseNotes) {
        $UpdateParams.ReleaseNotes = $ReleaseNotes
    }

    if ($IncrementVersion) {
        $CurrentVersion = (Test-ModuleManifest $ManifestFile).Version
        $NewVersion = "{0}.{1}.{2}" -f $CurrentVersion.Major, $CurrentVersion.Minor, ($CurrentVersion.Build + 1)
        $UpdateParams.ModuleVersion = $NewVersion
    }
    
    if ($ReleaseNotes -or $IncrementVersion) {
        Update-ModuleManifest @UpdateParams
    }
    
} else {
    $ManifestParams = @{ Path               = $ManifestFile
                        ModuleVersion      = '3.0.1'
                        Author             = 'Brian Addicks'
                        RootModule         = 'PowerAlto3.psm1'
                        CompanyName        = 'Lockstep Technology Group'
                        Description        = $Description
                        LicenseUri         = 'https://raw.githubusercontent.com/brianaddicks/poweralto3/master/LICENSE'
                        ProjectUri         = 'https://github.com/brianaddicks/poweralto3'
                        CmdletsToExport    = '*'
                        FunctionsToExport  = '*'
                        PowerShellVersion  = '5.0' }

    New-ModuleManifest @ManifestParams
}

