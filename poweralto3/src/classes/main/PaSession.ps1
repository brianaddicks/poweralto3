class PaSession {
    [double]$Id
    [string]$Vsys
    [string]$Application
    [string]$State
    [string]$Type
    [string]$Source
    [string]$SourcePort
    [string]$SourceZone
    [string]$SourceTranslatedIp
    [string]$SourceTranslatedPort
    [string]$Destination
    [string]$DestinationPort
    [string]$DestinationZone
    [string]$DestinationTranslatedIp
    [string]$DestinationTranslatedPort
    [string]$Protocol

    [datetime]$StartTime
}