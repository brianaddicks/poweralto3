# Get-PaAddressGroup

## Synopsis

Retrieves Address Group objects for a Palo Alto Device.

## Syntax


```powershell
Get-PaAddressGroup [[-Name] <String>] [[-Vsys] <String>] [[-Device] <String>] 
```

## Description

Retrieves Address Group objects for a Palo Alto Device.

## Examples

### Example 1

```
PS c:\> Get-PaAddressGroup
```


Returns all Address Groups for all Vsys/Devices configured.










### Example 2

```
PS c:\> Get-PaAddressGroup -Name "myaddress"
```

Returns all Address Groups named "myaddress" for all Vsys/Devices configured.










### Example 3

```
PS c:\> Get-PaAddressGroup -Name "myaddress" -Vsys "vsys1"
```

Returns Address Group named "myaddress" configured on "vsys1".










## Parameters

### -Name

Name of desired Address Group account to query.

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

Specifies the Vsys to query for configured Address Groups.

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

Specifies the Device to query for configured Address Groups (Panorama).

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


