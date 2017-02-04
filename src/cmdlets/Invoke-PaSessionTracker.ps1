function Invoke-PaSessionTracker {
    [CmdletBinding()]
	Param (
        [Parameter(Mandatory=$False)]
		[int]$Interval = 5,

        [Parameter(Mandatory=$False)]
		[array]$ShowProperties = @("Id","Application","Source","Destination","State","DestinationPort"),

        [Parameter(Mandatory=$False)]
		[int]$Count = 25,

        [Parameter(Mandatory=$False)]
		[string]$Application,

        [Parameter(Mandatory=$False)]
		[string]$Destination,

        [Parameter(Mandatory=$False)]
		[int]$DestinationPort,

        [Parameter(Mandatory=$False)]
		[string]$DestinationUser,

        [Parameter(Mandatory=$False)]
		[string]$EgressInterface,

        [Parameter(Mandatory=$False)]
		[string]$HwInterface,

        [Parameter(Mandatory=$False)]
		[string]$IngressInterface,

        [Parameter(Mandatory=$False)]
		[string]$SourceZone,

        [Parameter(Mandatory=$False)]
		[string]$DestinationZone,

        [Parameter(Mandatory=$False)]
		[string]$MinKb,

        [Parameter(Mandatory=$False)]
		[string]$Rule,

        [Parameter(Mandatory=$False)]
		[string]$NatRule,

        [Parameter(Mandatory=$False)]
		[string]$PbfRule,

        [Parameter(Mandatory=$False)]
		[string]$QosRule,

        [Parameter(Mandatory=$False)]
		[string]$QosClass,

        [Parameter(Mandatory=$False)]
		[string]$QosNodeId,

        [Parameter(Mandatory=$False)]
		[string]$Nat,

        [Parameter(Mandatory=$False)]
		[string]$Rematch,

        [Parameter(Mandatory=$False)]
		[string]$SslDecrypt,

        [Parameter(Mandatory=$False)]
		[string]$Type,

        [Parameter(Mandatory=$False)]
		[int]$Protocol,

        [Parameter(Mandatory=$False)]
		[string]$Source,

        [Parameter(Mandatory=$False)]
		[int]$SourcePort,

        [Parameter(Mandatory=$False)]
		[string]$SourceUser,

        [Parameter(Mandatory=$False)]
		[string]$State
    )

    $VerbosePrefix = "Invoke-PaSessionTracker:"
    
    $SessionParameters = $PSBOUNDPARAMETERS
    $SessionParameters.Remove("Interval") | Out-Null

    for ($i = 1;$i -eq 1) {
        $LengthValues = @()
        $OldSessions = $Sessions | Select-Object *
        $global:test2 = $OldSessions
        $Sessions = Get-PaSession @SessionParameters
        $Sessions = $Sessions[0..$Count]
        Clear-Host

        foreach ($p in $ShowProperties) {
            $global:test = $Sessions
            $PropertyType = $Sessions[0].$p.GetType().Name
            Write-Verbose "$VerbosePrefix Property '$p' is of type $PropertyName"

            $ValueMaxLength = 0
            foreach ($s in $sessions) {
                $CurrentLength = $s.$p.ToString().Length
                if ($CurrentLength -gt $ValueMaxLength) {
                    $ValueMaxLength = $CurrentLength
                }
            }
            
            if ($p.Length -gt $ValueMaxLength) {
                Write-Verbose "$VerbosePrefix CurrentValue: $ValueMaxLength; NameLength: $($p.Length)"
                $ValueMaxLength = $p.Length
            }
            $New = "" | Select-Object Name,MaxLength
            $New.Name = $p
            $New.MaxLength = $ValueMaxLength
            $LengthValues += $New
            Write-Verbose "$VerbosePrefix Name: $($New.Name); MaxLength: $($New.MaxLength)"
            $Header = $p.PadRight(($ValueMaxLength + 2)," ")
            Write-Host $Header -NoNewline
        }
        Write-Host
        $global:LengthValues = $LengthValues

        foreach ($Session in $Sessions) {
            $Lookup = $OldSessions | ? { $_.Id -eq $Session.Id }
            foreach ($p in $LengthValues) {
                $PropertyName = $p.Name
                Write-Verbose "$VerbosePrefix PropertyName: $PropertyName"
                $PropertyValue  = $Session.$PropertyName.ToString()
                Write-Verbose "$VerbosePrefix PropertyValue: $PropertyValue"
                $PropertyLength = $p.MaxLength
                Write-Verbose "$VerbosePrefix PropertyLength: $PropertyLength"
                $Value = [string]$PropertyValue.PadRight(($PropertyLength + 2)," ")

                $WriteHostParams = @{}
                $WriteHostParams.NoNewLine = $true
                $WriteHostParams.Object = $Value
                if (!($Lookup)) {
                    $WriteHostParams.ForegroundColor = "DarkBlue"
                } else {
                    $WriteHostParams.Remove("ForegroundColor")
                }
                switch ($PropertyName) {
                    "State" {
                        switch ($Value) {
                            {$_ -match "active"} {
                                $WriteHostParams.ForegroundColor = "DarkGreen"
                            }
                            {$_ -match "discard"} {
                                $WriteHostParams.ForegroundColor = "DarkRed"
                            }
                            default {
                                $WriteHostParams.Remove("ForegroundColor")
                            }
                        }
                        break
                    }
                }
                Write-Host @WriteHostParams
            }
            Write-Host
        }

        foreach ($Session in $OldSessions) {
            $Lookup = $Sessions | ? { $_.Id -eq $Session.Id }
            foreach ($p in $LengthValues) {
                $PropertyName = $p.Name
                Write-Verbose "$VerbosePrefix PropertyName: $PropertyName"
                $PropertyValue  = $Session.$PropertyName.ToString()
                Write-Verbose "$VerbosePrefix PropertyValue: $PropertyValue"
                $PropertyLength = $p.MaxLength
                Write-Verbose "$VerbosePrefix PropertyLength: $PropertyLength"
                $Value = [string]$PropertyValue.PadRight(($PropertyLength + 2)," ")

                $WriteHostParams = @{}
                $WriteHostParams.NoNewLine = $true
                $WriteHostParams.Object = $Value
                if (!($Lookup)) {
                    $WriteHostParams.ForegroundColor = "DarkGray"
                } else {
                    $WriteHostParams.Remove("ForegroundColor")
                }
<#                switch ($PropertyName) {
                    "State" {
                        switch ($Value) {
                            {$_ -match "active"} {
                                $WriteHostParams.ForegroundColor = "DarkGreen"
                            }
                            {$_ -match "discard"} {
                                $WriteHostParams.ForegroundColor = "DarkRed"
                            }
                            default {
                                $WriteHostParams.Remove("ForegroundColor")
                            }
                        }
                        break
                    }
                }#>
                Write-Host @WriteHostParams
            }
            Write-Host
        }
        Start-Sleep $Interval
    }
}