function Get-PaSession {
    [CmdletBinding()]
	Param (
		[Parameter(Mandatory=$False,ParameterSetName="id")]
		[int]$Id,

        [Parameter(Mandatory=$False,ParameterSetName="filter")]
		[string]$Application,

        [Parameter(Mandatory=$False,ParameterSetName="filter")]
		[int]$Count,

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

    $VerbosePrefix = "Invoke-PaSession:"

    $CheckConnection = $global:PaDeviceObject.checkConnectionStatus($VerbosePrefix)

    return $global:PaDeviceObject.invokeOperationalQuery($Command)
}