# Get-PaAdmin

## Synopsis

Pulls locally configured Administrator accounts for a Palo Alto Device.

## Syntax


```powershell
Get-PaAdmin [[-Name] <String>] [[-Vsys] <String>] [[-Device] <String>] 
```

## Description

Pulls locally configured Administrator accounts for a Palo Alto Device.

## Examples

### Example 1

```
PS c:\> Get-PaAdmin
```


Returns all locally configured Administrator accounts.










### Example 2

```
PS c:\> Get-PaAdmin -Name "myadmin"
```

Returns a single Administrator account named "myadmin".










## Parameters

### -Name

Name of desired Administrator account to query.

```asciidoc
Type: String
Parameter Sets: All
Aliases: 

Required: false
Position: 1
Default value: 
Accept pipeline input: false
Accept wildcard characters: false
```
### -Vsys

Specifies the Vsys to query Administrator accounts in.

```asciidoc
Type: String
Parameter Sets: All
Aliases: 

Required: false
Position: 2
Default value: 
Accept pipeline input: false
Accept wildcard characters: false
```
### -Device

Specifies the Device to query accounts from in Panorama.

```asciidoc
Type: String
Parameter Sets: All
Aliases: 

Required: false
Position: 3
Default value: 
Accept pipeline input: false
Accept wildcard characters: false
```


