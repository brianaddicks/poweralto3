function Invoke-PaSessionTracker {
    [CmdletBinding()]
	Param (
        [Parameter(Mandatory=$False)]
		[int]$Interval = 5,

        [Parameter(Mandatory=$False)]
		[array]$ShowProperties = @("StartTime","Id","Application","Source","Destination","State","DestinationPort"),

        [Parameter(Mandatory=$False)]
		[int]$Count = 40,

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
		[string]$State,

        [Parameter(Mandatory=$False)]
		[switch]$NoClear
    )

    $VerbosePrefix = "Invoke-PaSessionTracker:"
    
    $SessionParameters = $PSBOUNDPARAMETERS
    $SessionParameters.Remove("Interval") | Out-Null
    $SessionParameters.Remove("ShowProperties") | Out-Null
    $SessionParameters.Remove("NoClear") | Out-Null

    for ($i = 1;$i -eq 1) {
        $LengthValues = @()
        $OldSessions = $AllSessions | Select-Object *
        $global:test2 = $OldSessions
        
        $Sessions = Get-PaSession @SessionParameters
        $NewSessions = @()
        foreach ($Session in $Sessions) {
            $Lookup = $OldSessions | Where-Object { $_.Id -eq $Sessions.Id }
            if (!($Lookup)) {
                $NewSessions += $Session | Select-Object *,TickCount
            }
        }
        $NewSessions = $NewSessions[0..($Count - 1)]




        if ($NewSessions.Count -lt $Count) {
            $AvailableCount = $Count - $NewSessions.Count
            $OldSessions = $OldSessions[0..($AvailableCount - 1)]
        }
        $AllSessions = $NewSessions + $OldSessions
        $AllSessions = $AllSessions | Sort-Object StartTime -Descending
        $AllSessions = $AllSessions | Select-Object * | Sort-Object Id -Descending
        $global:test3 = $AllSessions

        if (!($NoClear)) {
            Clear-Host
        }

        # Write top block of info.
        Write-Host "Total Sessions Matched: $($Sessions.Count)"
        Write-Host "Sessions Shown: $($AllSessions.Count)"
        Write-Host ""

        # Find Column Length and output Headers
        foreach ($p in $ShowProperties) {

            # Find length of header
            if ($p -eq "TickCount") {
                $ValueMaxLength = 0
            } else {
                $global:test = $Sessions

                $ValueMaxLength = 0
                foreach ($s in $AllSessions) {
                    $CurrentLength = $s.$p.ToString().Length
                    if ($CurrentLength -gt $ValueMaxLength) {
                        $ValueMaxLength = $CurrentLength
                    }
                }
            }
            if ($p.Length -gt $ValueMaxLength) {
                Write-Verbose "$VerbosePrefix CurrentValue: $ValueMaxLength; NameLength: $($p.Length)"
                $ValueMaxLength = $p.Length
            }

            # Log Column Lengths
            $New = "" | Select-Object Name,MaxLength
            $New.Name = $p
            $New.MaxLength = $ValueMaxLength
            $LengthValues += $New
            Write-Verbose "$VerbosePrefix Name: $($New.Name); MaxLength: $($New.MaxLength)"

            # Write Headers
            $Header = $p.PadRight(($ValueMaxLength + 2)," ")
            Write-Host $Header -NoNewline
        }
        
        # Add NewLine after Headers
        Write-Host
        $global:LengthValues = $LengthValues



        $SessionCounter = 0
        foreach ($Session in $AllSessions) {
            if ($Session.TickCount -gt 0) {
                $Session.TickCount++
            } else {
                $Session.TickCount = 1
            }
            
            $SessionCounter++
            $SessionCounterString = "$SessionCounter".PadRight(3," ")
            Write-Host $SessionCounterString -NoNewline

            $Lookup = $OldSessions | Where-Object { $_.Id -eq $Session.Id }
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
        Start-Sleep $Interval
    }
}