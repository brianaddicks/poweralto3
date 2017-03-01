$ScriptPath = Split-Path $($MyInvocation.MyCommand).Path
$ModuleName = Get-Location | Split-Path -Leaf

# Sources
$SourceDirectory = "src"
$SourcePath = $ScriptPath + "/" + $SourceDirectory

$CmdletPath = $SourcePath + "/" + "cmdlets"
$HelperPath = $SourcePath + "/" + "helpers"
$ClassPath  = $SourcePath + "/" + "classes"

# Destinations
$DestinationDirectory = "module"
$DestinationPath = $ScriptPath + "/" + $DestinationDirectory

$ModuleFile   = $DestinationPath + "/" + $ModuleName + ".psm1"
$ManifestFile = $DestinationPath + "/" + $ModuleName + ".psd1"

###############################################################################
# Create Manifest

# PsGallery requires: module name, version, description, and author

$Description = "PowerAlto provides an interface to the Palo Alto Firewall API."

$ManifestParams = @{ Path               = $ManifestFile
                     ModuleVersion      = '3.0'
                     Author             = 'Brian Addicks'
                     RootModule         = 'PowerAlto3.psm1'
                     CompanyName        = 'Lockstep Technology Group'
                     Description        = $Description
                     LicenseUri         = 'https://raw.githubusercontent.com/brianaddicks/poweralto3/master/LICENSE'
                     ProjectUri         = 'https://github.com/brianaddicks/poweralto3'
                     PowerShellVersion  = '5.0' }

New-ModuleManifest @ManifestParams

###############################################################################
# Headers

$ClassHeader = @'
###############################################################################
## Powershell v5 Classes
###############################################################################


'@


$CmdletHeader = @'
###############################################################################
## Start Powershell Cmdlets
###############################################################################


'@

$HelperHeader = @'
###############################################################################
## Start Helper Functions
###############################################################################


'@

$Footer = @'
###############################################################################
## Export Cmdlets
###############################################################################

Export-ModuleMember *-*
'@

$FunctionHeader = @'
###############################################################################
# 
'@

###############################################################################
# Add Cmdlets

# Combining function
function CombinePsFiles {
    [CmdletBinding()]
    [OutputType([String])]
    Param (
    	[Parameter(Mandatory=$True,Position=0)]
		[array]$CmdletFiles,

        [Parameter(Mandatory=$False,Position=1)]
        [array]$HelperFiles,

        [Parameter(Mandatory=$False,Position=2)]
        [array]$ClassFiles,

        [Parameter(Mandatory=$False)]
        [string]$CmdletHeader,

        [Parameter(Mandatory=$False)]
        [string]$HelperHeader,

        [Parameter(Mandatory=$False)]
        [string]$FunctionHeader,

        [Parameter(Mandatory=$False)]
        [string]$Footer
    )

    $ReturnObject = @()
    
    # Add Classes
    $ReturnObject += $ClassHeader

    foreach ($File in $ClassFiles) {
        $File = Get-ChildItem $File.FullName
        $ReturnObject += ($FunctionHeader + $File.BaseName)
        $ReturnObject += Get-Content $File
        $ReturnObject += ""
    }

    # Add Cmdlets
    $ReturnObject += $CmdletHeader

    foreach ($File in $CmdletFiles) {
        $File = Get-ChildItem $File.FullName
        $ReturnObject += ($FunctionHeader + $File.BaseName)
        $ReturnObject += Get-Content $File
        $ReturnObject += ""
    }

    # Add Helpers
    if ($HelperFiles) {
        $ReturnObject += $HelperHeader

        foreach ($File in $HelperFiles) {
            $File = Get-ChildItem $File.FullName
            $ReturnObject += ($FunctionHeader + $File.BaseName)
            $ReturnObject += Get-Content $File
            $ReturnObject += ""
        }
    }

    $ReturnObject += $Footer

    return $ReturnObject
}

# List Class files in correct order
$ClassFiles = @()
$ClassFiles += Get-ChildItem ($ClassPath + '/base')
$ClassFiles += Get-ChildItem ($ClassPath + '/helper')
$ClassFiles += Get-ChildItem ($ClassPath + '/main')

# do the combine
$CombineParams = @{}
$CombineParams.CmdletFiles    = Get-ChildItem $CmdletPath
if ((Get-ChildItem $HelperPath).Count -gt 0) {
    $CombineParams.HelperFiles    = Get-ChildItem $HelperPath
}
$CombineParams.ClassFiles     = $ClassFiles
$CombineParams.CmdletHeader   = $CmdletHeader
$CombineParams.HelperHeader   = $HelperHeader
$CombineParams.FunctionHeader = $FunctionHeader
$CombineParams.Footer         = $Footer

$Output = CombinePsFiles @CombineParams

$Output | Out-File $ModuleFile -Force