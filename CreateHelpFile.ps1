[CmdletBinding()]
Param (
    [Parameter(Mandatory=$True,Position=0)]
    [string]$Cmdlet,

    [Parameter(Mandatory=$True,Position=1)]
    [string]$Destination
)

$CmdletInfo = Get-Command $Cmdlet
$Output = @()

# Header
$Output += "# $($CmdletInfo.Name)"




# Output File
$Output | Out-File $Destination