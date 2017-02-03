function Get-PaSession {
    [CmdletBinding()]
	Param (
		[Parameter(Mandatory=$False,ParameterSetName="id")]
		[int]$Id,

        [Parameter(Mandatory=$False,ParameterSetName="filter")]
		[string]$Application,

        [Parameter(Mandatory=$False,ParameterSetName="filter")]
		[string]$Destination,

        [Parameter(Mandatory=$False,ParameterSetName="filter")]
		[int]$DestinationPort,

        [Parameter(Mandatory=$False,ParameterSetName="filter")]
		[string]$DestinationUser,

        [Parameter(Mandatory=$False,ParameterSetName="filter")]
		[string]$EgressInterface,

        [Parameter(Mandatory=$False,ParameterSetName="filter")]
		[string]$HwInterface,

        [Parameter(Mandatory=$False,ParameterSetName="filter")]
		[string]$IngressInterface,

        [Parameter(Mandatory=$False,ParameterSetName="filter")]
		[string]$SourceZone,

        [Parameter(Mandatory=$False,ParameterSetName="filter")]
		[string]$DestinationZone,

        [Parameter(Mandatory=$False,ParameterSetName="filter")]
		[string]$MinKb,

        [Parameter(Mandatory=$False,ParameterSetName="filter")]
		[string]$Rule,

        [Parameter(Mandatory=$False,ParameterSetName="filter")]
		[string]$NatRule,

        [Parameter(Mandatory=$False,ParameterSetName="filter")]
		[string]$PbfRule,

        [Parameter(Mandatory=$False,ParameterSetName="filter")]
		[string]$QosRule,

        [Parameter(Mandatory=$False,ParameterSetName="filter")]
		[string]$QosClass,

        [Parameter(Mandatory=$False,ParameterSetName="filter")]
		[string]$QosNodeId,

        [Parameter(Mandatory=$False,ParameterSetName="filter")]
		[string]$Nat,

        [Parameter(Mandatory=$False,ParameterSetName="filter")]
		[string]$Rematch,

        [Parameter(Mandatory=$False,ParameterSetName="filter")]
		[string]$SslDecrypt,

        [Parameter(Mandatory=$False,ParameterSetName="filter")]
		[string]$Type,

        [Parameter(Mandatory=$False,ParameterSetName="filter")]
		[int]$Protocol,

        [Parameter(Mandatory=$False,ParameterSetName="filter")]
		[string]$Source,

        [Parameter(Mandatory=$False,ParameterSetName="filter")]
		[int]$SourcePort,

        [Parameter(Mandatory=$False,ParameterSetName="filter")]
		[string]$SourceUser,

        [Parameter(Mandatory=$False,ParameterSetName="filter")]
		[double]$StartAt,

        [Parameter(Mandatory=$False,ParameterSetName="filter")]
		[string]$State
    )

    $VerbosePrefix = "Get-PaSession:"

    $Filters = @{ "Application"      = "application"
                  "Destination"      = "destination"
                  "DestinationPort"  = "destination-port"
                  "DestinationUser"  = "destination-user"
                  "EgressInterface"  = "egress-interface"
                  "HwInterface"      = "hw-interface"
                  "IngressInterface" = "ingress-interface"
                  "SourceZone"       = "from"
                  "DestinationZone"  = "to"
                  "MinKb"            = "min-kb"
                  "Rule"             = "rule"
                  "NatRule"          = "nat-rule"
                  "PbfRule"          = "pbf-rule"
                  "QosRule"          = "qos-rule"
                  "QosClass"         = "qos-class"
                  "QosNodeId"        = "qos-node-id"
                  "Nat"              = "nat"
                  "Rematch"          = "rematch"
                  "SslDecrypt"       = "ssl-descrypt"
                  "Type"             = "type"
                  "Protocol"         = "protocol"
                  "Source"           = "source"
                  "SourcePort"       = "source-port"
                  "SourceUser"       = "source-user"
                  "StartAt"          = "start-at"
                  "State"            = "state" }

    $Command = "<show><session>"
    
    if ($Id) {
        $Command += "<id>$Id</id>"
    } else {
        $Command += "<all><filter>"
        foreach ($Filter in $Filters.GetEnumerator()) {
            try {
                $FilterValue = Get-Variable -Name $Filter.Name -ValueOnly
                if ($FilterValue) {
                    $Command += "<" + $Filter.Value + ">" + $FilterValue + "</" + $Filter.Value + ">"
                }
            } catch {}
        }
        $Command += "</filter></all>"
    }

    $Command += "</session></show>"
    Write-Verbose "$VerbosePrefix Command: $Command"

    $Results = Invoke-PaOperation $Command
    if ($Id) {
        $Results = $Results.response.result
    } else {
        $Results = $Results.response.result.entry
    }

    $ReturnResults = @()
    foreach ($Result in $Results) {
        $Session = New-Object PaSession

        if ($Id) {
            $Session.Id = $Id
        } else {
            $Session.Id = $Result.idx
        }

        $Session.Vsys                      = $Result.vsys
        $Session.Application               = $Result.application

        if ($Result.c2s) {
            $Session.State                     = $Result.c2s.state
            $Session.Type                      = $Result.c2s.type
            $Session.Source                    = $Result.c2s.source
            $Session.SourcePort                = $Result.c2s.sport
            $Session.SourceZone                = $Result.c2s.'source-zone'
            $Session.Destination               = $Result.c2s.dst
            $Session.DestinationPort           = $Result.c2s.dport
            $Session.Protocol                  = $Result.c2s.proto
            
            $Session.DestinationZone           = $Result.s2c.'source-zone'
            $Session.SourceTranslatedIp        = $Result.s2c.dst
            $Session.SourceTranslatedPort      = $Result.s2c.dport
            $Session.DestinationTranslatedIp   = $Result.s2c.source
            $Session.DestinationTranslatedPort = $Result.s2c.sport
        } else {
            $Session.State                     = $Result.state
            $Session.Type                      = $Result.type
            $Session.Source                    = $Result.source
            $Session.SourcePort                = $Result.sport
            $Session.SourceZone                = $Result.from
            $Session.SourceTranslatedIp        = $Result.xsource
            $Session.SourceTranslatedPort      = $Result.xsport
            $Session.Destination               = $Result.dst
            $Session.DestinationPort           = $Result.dport
            $Session.DestinationZone           = $Result.to
            $Session.DestinationTranslatedIp   = $Result.xdst
            $Session.DestinationTranslatedPort = $Result.xdport
            $Session.Protocol                  = $Result.proto
        }

        $ReturnResults += $Session 
    }

    return $ReturnResults
}