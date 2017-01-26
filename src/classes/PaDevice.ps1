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
    [array]$UrlHistory
    [array]$RawQueryResultHistory

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
        $formattedQueryString = [HelperWebTools]::createQueryString($queryString)
        $url = $this.getApiUrl() + $formattedQueryString
        if ($queryString.type -ne "keygen") {
            $this.UrlHistory += $url
        } else {
            $formattedQueryString = [HelperWebTools]::createQueryString($queryString)
            $this.UrlHistory += $url.Replace($queryString.password,"PASSWORDREDACTED")
        }
        $rawResult = Invoke-WebRequest -Uri $url -SkipCertificateCheck
        $this.RawQueryResultHistory += $rawResult
        $result = [xml]($rawResult.Content)

        # Handle Errors
        if ($result.response.status -ne "success") {
            $errorMessage = $result.response.status + " " + $result.response.code + ": " + $result.response.result.msg
            Throw $errorMessage
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

    # Keygen API Query
    [xml] invokeKeygenQuery([string]$user,[string]$password) {
        $queryString = @{}
        $queryString.type = "keygen"
        $queryString.user = $user
        $queryString.password = $password
        $result = $this.invokeApiQuery($queryString)
        $this.ApiKey = $result.response.result.key
        return $result
    }

    # Keygen API Query
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