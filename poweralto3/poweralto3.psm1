###############################################################################
## Powershell v5 Classes
###############################################################################

#Get public and private function definition files.
    $Helpers        = @( Get-ChildItem -Path $PSScriptRoot\src\helpers\*.ps1 -ErrorAction SilentlyContinue )
    $HelperClasses  = @( Get-ChildItem -Path $PSScriptRoot\src\classes\helper\*.ps1 -ErrorAction SilentlyContinue )
	$BaseClasses    = @( Get-ChildItem -Path $PSScriptRoot\src\classes\base\*.ps1 -ErrorAction SilentlyContinue )
	$MainClasses    = @( Get-ChildItem -Path $PSScriptRoot\src\classes\main\*.ps1 -ErrorAction SilentlyContinue )
	$Cmdlets        = @( Get-ChildItem -Path $PSScriptRoot\src\cmdlets\*.ps1 -ErrorAction SilentlyContinue )
	$global:test = $Cmdlets

#Dot source the files
    Foreach($import in @($Helpers + $HelperClasses + $BaseClasses + $MainClasses + $Cmdlets))
    {
        Try
        {
            . $import.fullname
        }
        Catch
        {
            Write-Error -Message "Failed to import function $($import.fullname): $_"
        }
    }

# Here I might...
    # Read in or create an initial config file and variable
    # Export Public functions ($Public.BaseName) for WIP modules
    # Set variables visible to the module and its functions only

Export-ModuleMember -Function $Cmdlets.BaseName