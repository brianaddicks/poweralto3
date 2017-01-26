class PaDevice {
    [ValidateRange(1,65535)]
    [int]$Port = 443
    
    [string]$ApiKey

    [ValidateSet('http','https')] 
    [string]$Protocol = "https"

    # DeviceAddress
    hidden [string]$DeviceAddress

    setDeviceAddress([string]$deviceAddress) {
        $this.DeviceAddress = [HelperRegex]::isFqdnOrIpv4($deviceAddress,"Device must be a valid FQDN or IPv4 Address.")
    }

    [string] getDeviceAddress() {
        return $this.DeviceAddress
    }

    # Track usage
    [array]$UrlHistory

    # Function for created the base API Url
    [String] getApiUrl() {
        if ($this.DeviceAddress) {
            $url = $this.Protocol + "://" + $this.DeviceAddress + ":" + $this.Port + "/api/"
            return $url
        } else {
            return $null
        }
    }

    # Base API Query
    [Xml] invokeApiQuery([hashtable]$queryString) {
        $formattedQueryString = [HelperWebTools]::createQueryString($queryString)
        $url = $this.getApiUrl() + $formattedQueryString
        if ($queryString.type -ne "keygen") {
            $this.UrlHistory += $url
        } else {
            $this.UrlHistory += $url.Replace($queryString.password,"PASSWORDREDACTED")
        }
        $rawResult = Invoke-WebRequest -Uri $url -SkipCertificateCheck
        $result = [xml]($rawResult.Content)
        return $result
    }

    # Config API Query
    [Xml] invokeConfigQuery([string]$xPath,[string]$action) {
        $queryString = @{}
        $queryString.key = $this.ApiKey
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
}