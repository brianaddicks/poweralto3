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
$ManifestParams = @{ Path = $ManifestFile
                     ModuleVersion      = '3.0'
                     Author             = 'Brian Addicks'
                     RootModule         = 'PowerAlto3.psm1'
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

$HelperFunctionHeader = @'
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
    Param (
    	[Parameter(Mandatory=$True,Position=0)]
		[array]$CmdletFiles,

        [Parameter(Mandatory=$True,Position=1)]
        [array]$HelperFiles,

        [Parameter(Mandatory=$True,Position=2)]
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
        $File = ls $File.FullName
        $ReturnObject += ($FunctionHeader + $File.BaseName)
        $ReturnObject += gc $File
        $ReturnObject += ""
    }

    # Add Cmdlets
    $ReturnObject += $CmdletHeader

    foreach ($File in $CmdletFiles) {
        $File = ls $File.FullName
        $ReturnObject += ($FunctionHeader + $File.BaseName)
        $ReturnObject += gc $File
        $ReturnObject += ""
    }

    # Add Helpers
    $ReturnObject += $HelperHeader

    foreach ($File in $HelperFiles) {
        $File = ls $File.FullName
        $ReturnObject += ($FunctionHeader + $File.BaseName)
        $ReturnObject += gc $File
        $ReturnObject += ""
    }

    $ReturnObject += $Footer

    return $ReturnObject
}

# List Class files in correct order
$ClassFiles = @()
$ClassFiles += ls ($ClassPath + '/base')
$ClassFiles += ls ($ClassPath + '/helper')
$ClassFiles += ls ($ClassPath + '/main')

# do the combine
$CombineParams = @{}
$CombineParams.CmdletFiles    = ls $CmdletPath
$CombineParams.HelperFiles    = ls $HelperPath
$CombineParams.ClassFiles     = $ClassFiles
$CombineParams.CmdletHeader   = $CmdletHeader
$CombineParams.HelperHeader   = $HelperHeader
$CombineParams.FunctionHeader = $FunctionHeader
$CombineParams.Footer         = $Footer

$Output = CombinePsFiles @CombineParams

$Output | Out-File $ModuleFile -Force