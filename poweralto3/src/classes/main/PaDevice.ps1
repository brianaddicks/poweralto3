class PaDevice {
    [ValidateRange(1,65535)]
    [int]$Port = 443
    
    [string]$ApiKey

    [ValidateSet('http','https')] 
    [string]$Protocol = "https"

    [string]$Name
    [string]$IpAddress
    [string]$Model
    [string]$Serial
    [string]$OsVersion
    [string]$GpAgent
    [string]$AppVersion
    [string]$ThreatVersion
    [string]$WildFireVersion
    [string]$UrlVersion

    # DeviceAddress
    hidden [string]$DeviceAddress

    setDeviceAddress([string]$deviceAddress) {
        $this.DeviceAddress = [HelperRegex]::isFqdnOrIpv4($deviceAddress,"DeviceAddress must be a valid FQDN or IPv4 Address.")
    }

    [string] getDeviceAddress() {
        $returnValue = [HelperRegex]::isFqdnOrIpv4($this.DeviceAddress,"DeviceAddress must be a valid FQDN or IPv4 Address.")
        return $returnValue
    }

    # Track usage
    hidden [bool]$Connected
    [array]$UrlHistory
    [array]$RawQueryResultHistory
    [array]$QueryHistory
    $LastError
    $LastResult

    # Error handling
    [bool] checkConnectionStatus([string]$errorPrefix) {
        if ($this.Connected) {
            return $true
        } else {
            throw "$errorPrefix Not Connected, please use Get-PaConfig to connect before using other cmdlets."
        }
    }

    # Function for created the base API Url
    [String] getApiUrl() {
        if ($this.DeviceAddress) {
            $url = $this.Protocol + "://" + $this.getDeviceAddress() + ":" + $this.Port + "/api/"
            return $url
        } else {
            return $null
        }
    }

    ############################################################################################
    # Api Query Functions

    # Base API Query
    [Xml] invokeApiQuery([hashtable]$queryString) {
        if ($queryString.type -ne "keygen") {
            $queryString.key = $this.ApiKey
        }
        $formattedQueryString = [HelperWeb]::createQueryString($queryString)
        $url = $this.getApiUrl() + $formattedQueryString
        if ($queryString.type -ne "keygen") {
            $this.UrlHistory += $url
            $this.QueryHistory += $queryString
        } else {
            $formattedQueryString = [HelperWeb]::createQueryString($queryString)
            $this.UrlHistory += $url.Replace($queryString.password,"PASSWORDREDACTED")
        }
        try {
            #$ProgressPreferenceRemember = $ProgressPreference
	        $ProgressPreference = "SilentlyContinue"
            $rawResult = Invoke-WebRequest -Uri $url -SkipCertificateCheck
            #$env:ProgressPreference = $ProgressPreferenceRemember
        } catch {
            Throw "$($error[0].ToString()) $($error[0].InvocationInfo.PositionMessage)"
        }
        $this.RawQueryResultHistory += $rawResult
        $result = [xml]($rawResult.Content)
        $this.LastResult = $result

        # Handle Errors
        if ($result.response.status -ne "success") {
            $errorMessage = "PaDevice: " + $result.response.status + " " + $result.response.code + ": "
            if ($result.response.msg.line) {
                if ($result.response.msg.line."#cdata-section") {
                    $errorMessage += "Too Many errors, check `$global:PaDeviceObject.LastError for more details."
                    $this.LastError = $result.response.msg.line."#cdata-section"
                } else {
                    $errorMessage += $result.response.msg.line
                    $this.LastError = $result.response.msg.line
                }
            } else {
                $errorMessage += $result.response.result.msg
                $this.LastError = $result.response.result.msg
            }

            switch ($errorMessage) {
                { $_ -match "No such node" } {
                    Write-Warning $errorMessage
                    break
                }
                default {
                    Throw $errorMessage
                }
            }
        }

        return $result
    }

    # Config API Query
    [Xml] invokeConfigQuery([string]$xPath,[string]$action) {
        $queryString = @{}
        $queryString.type = "config"
        $queryString.action = $action
        $queryString.xpath = $xPath
        $result = $this.invokeApiQuery($queryString)
        return $result
    }

    [Xml] invokeConfigQuery([string]$xPath,[string]$action,[string]$element) {
        $queryString         = @{}
        $queryString.type    = "config"
        $queryString.action  = $action
        $queryString.xpath   = $xPath
        $queryString.element = $element

        $result = $this.invokeApiQuery($queryString)
        return $result
    }

    # Keygen API Query
    [xml] invokeKeygenQuery([PSCredential]$credential) {
        $queryString = @{}
        $queryString.type = "keygen"
        $queryString.user = $credential.UserName
        $queryString.password = $Credential.getnetworkcredential().password
        $result = $this.invokeApiQuery($queryString)
        $this.ApiKey = $result.response.result.key
        return $result
    }
    

    # Operational API Query
    [xml] invokeOperationalQuery([string]$cmd) {
        $queryString = @{}
        $queryString.type = "op"
        $queryString.cmd = $cmd
        $result = $this.invokeApiQuery($queryString)
        return $result
    }

    # Test Connection
    [bool] testConnection() {
        $result = $this.invokeOperationalQuery('<show><system><info></info></system></show>')
        $this.Connected       = $true
        $this.Name            = $result.response.result.system.devicename
        $this.IpAddress       = $result.response.result.system.'ip-address'
        $this.Model           = $result.response.result.system.model
        $this.Serial          = $result.response.result.system.serial
        $this.OsVersion       = $result.response.result.system.'sw-version'
        $this.GpAgent         = $result.response.result.system.'global-protect-client-package-version'
        $this.AppVersion      = $result.response.result.system.'app-version'
        $this.ThreatVersion   = $result.response.result.system.'threat-version'
        $this.WildFireVersion = $result.response.result.system.'wildfire-version'
        $this.UrlVersion      = $result.response.result.system.'url-filtering-version'
        return $true
    }
}