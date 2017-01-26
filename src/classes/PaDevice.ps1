class PaDevice {
    [string]$Device
    [int]$Port = 443
    [string]$ApiKey
    [string]$Protocol = "https"

    # Track usage
    [array]$UrlHistory

    # Constructor
    PaDevice ([string]$Device) {
        $this.Device  = [HelperRegex]::isFqdnOrIpv4($Device,"Device must be a valid FQDN or IPv4 Address.")
    }

    [String] getApiUrl() {
        if ($this.Device) {
            $url = $this.Protocol + "://" + $this.Device + ":" + $this.Port + "/api/"
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
            $this.UrlHistory += $url -replace $queryString.password,"PASSWORDREDACTED"
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