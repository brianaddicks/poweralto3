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

    $StopWatch  = [System.Diagnostics.Stopwatch]::StartNew() # used by Write-Progress so it doesn't slow the whole function down

    # Header Function
    function WriteHeader([int]$TotalSessionsMatched,[int]$ShownSessions) {
        # Write top block of info.
        Write-Host "Total Sessions Matched: $TotalSessionsMatched"
        Write-Host "Sessions Shown: $ShownSessions"
        Write-Host ""
    }

    # GetColumnLengths
    function GetColumnLengths([array]$PropertiesDisplayed,[array]$Data) {
        $ColumnLengths = @()
        foreach ($Property in $PropertiesDisplayed) {
            $CurrentMaxLength = $Property.Length
            switch ($Property) {
                TickCount {
                    break
                }
                default {
                    foreach ($Datum in $Data) {
                        $CurrentLength = $Datum.$Property.ToString().Length
                        if ($CurrentLength -gt $CurrentMaxLength) {
                            $CurrentMaxLength = $CurrentLength
                        }
                    }
                }
            }

            # Create Object add to array
            $NewObject               = "" | Select-Object PropertyName,MaxLength
            $NewObject.PropertyName  = $Property
            $NewObject.MaxLength     = $CurrentMaxLength
            $ColumnLengths          += $NewObject
        }

        return $ColumnLengths
    }

    # WriteColumnHeaders
    function WriteColumnHeaders([array]$ColumnLengths) {
        # Selection
        Write-Host "  " -NoNewline
        # Count
        Write-Host "   " -NoNewline
        
        # Headers
        foreach ($Column in $ColumnLengths) {
            $ColumnLabel = $Column.PropertyName
            $Length      = $Column.MaxLength
            $ColumnLabel = $ColumnLabel.PadRight(($Length + 2)," ")
            
            Write-Host $ColumnLabel -NoNewline
        }
        Write-Host
    }



    While ($vkeycode -ne 81) {
        #$press = $host.ui.rawui.readkey("NoEcho,IncludeKeyDown")
        #$vkeycode = $press.virtualkeycode

        $OldSessions = $AllSessions | Select-Object *
        $Sessions = Get-PaSession @SessionParameters | Sort-Object StartTime
        $NewSessions = @()
        foreach ($Session in $Sessions[0..($Count-1)]) {
            $Lookup = $OldSessions | Where-Object { $_.Id -eq $Session.Id }
            if (!($Lookup)) {
                $NewSessions += $Session | Select-Object *,TickCount,Selected
            }
        }

        # Get proper number of OldSessions
        
        if (($NewSessions.Count -lt $Count) -and ($OldSessions.Count -gt 0)) {
            $AvailableCount = $Count - $NewSessions.Count
            $OldSessions = $OldSessions[0..($AvailableCount - 1)]
            $AllSessions = $NewSessions + $OldSessions
        } else {
            $AllSessions = $NewSessions
        }

        
        $AllSessions = $AllSessions | Select-Object * | Sort-Object StartTime -Descending
        $global:test3 = $AllSessions

        $LoopCount = 1
        while ($StopWatch.Elapsed.TotalMilliseconds -lt ($Interval * 1000)) {
                if (!($NoClear)) {
                    Clear-Host
                }

                # Write Header Block
                WriteHeader $Sessions.Count $AllSessions.Count
                
                #Extra Space for line counter
                Write-Host "     " -NoNewLine

                # Find Column Length and output Headers
                $LengthValues = @()
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
                    if ($p -eq "StartTime") {
                        $New.MaxLength = ([string](Get-Date -Format "MM/dd/yy HH:mm:ss")).Length
                    } else {
                        $New.MaxLength = $ValueMaxLength
                    }
                    $LengthValues += $New
                    Write-Verbose "$VerbosePrefix Name: $($New.Name); MaxLength: $($New.MaxLength)"

                    # Write Headers
                    $Header = $p.PadRight(($ValueMaxLength + 2)," ")
                    Write-Host $Header -NoNewline
                }
                
                # Add NewLine after Headers
                Write-Host
            
                $SessionCounter = 0
                foreach ($Session in $AllSessions) {
                    if ($Session.TickCount -gt 0) {
                        $Session.TickCount++
                    } else {
                        $Session.TickCount = 1
                    }
                    
                    if ($Session.Selected) {
                        Write-Host "*" -NoNewline
                    } else {
                        Write-Host " " -NoNewline
                    }
                    
                    $SessionCounter++
                    $SessionCounterString = "$SessionCounter".PadRight(3," ")
                    Write-Host $SessionCounterString -NoNewline

                    $Lookup = $OldSessions | Where-Object { $_.Id -eq $Session.Id }
                    $ReverseLookup = $Sessions | Where-Object { $_.Id -eq $Session.Id }

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

                        # Format Date, I suspect there's a better way to handle this
                        if ($PropertyName -eq "StartTime") {
                            $WriteHostParams.Object = ([string](Get-Date -Date $Value -Format "MM/dd/yy HH:mm:ss")).PadRight(($PropertyLength + 2)," ")
                        } else {
                            $WriteHostParams.Object = $Value
                        }

                        if (($ReverseLookup) -and (!($Lookup))) {
                            # New Session
                            $WriteHostParams.ForegroundColor = "DarkBlue"
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
                                            # Don't change anything (yet)
                                        }
                                    }
                                    break
                                }
                            }
                        } elseif (($Lookup) -and (!($ReverseLookup))) {
                            # Inactive Session
                            $WriteHostParams.ForegroundColor = "DarkGray"
                        }
                        Write-Host @WriteHostParams
                    }
                    Write-Host
                }

                # Write blank lines
                $BlankLines = $Count - $AllSessions.Count
                for ($b = 0;$b -lt $BlankLines;$b++) {
                    Write-Host
                }

            #Start-Sleep $Interval
            # Show Progress Bar between API Calls
<#
            if ($StopWatch.Elapsed.TotalMilliseconds -ge ($LoopCount * 1000)) {
                $LoopCount++
                $PercentComplete = [math]::truncate($LoopCount / $Interval * 100)
                Write-Progress -Activity "Waiting to refresh sessions: $($Interval - $LoopCount)..." -PercentComplete $PercentComplete
                if ($StopWatch.Elapsed.TotalMilliseconds -ge ($Interval * 1000)) {
                    $StopWatch.Reset()
                    $StopWatch.Start()
                    $LoopCount = 1
                    Write-Progress -Activity "Refreshing..." -PercentComplete 100 -Completed
                }
            }#>
<#
            for ($p = 0;$p -lt $Interval;$p++) {
                $PercentComplete = ($p / $Interval) * 100
                $Activity = "Waiting to refresh sessions: $($Interval - $p)..."
                Write-Progress -Activity $Activity -PercentComplete $PercentComplete
                Start-Sleep 1
            }
            Write-Progress -Activity "Refreshing..." -PercentComplete 100#>
            
        }
    }
}