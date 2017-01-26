class HelperWebTools {
    static [string] createQueryString ([hashtable]$hashTable) {
        $i = 0
        $queryString = "?"
        foreach ($hash in $hashTable.GetEnumerator()) {
            $i++
            $queryString += $hash.Name + "=" + $hash.Value
            if ($i -lt $HashTable.Count) {
                $queryString += "&"
            }
        }
        return $queryString
    }
}

class PaDevice {
    [string]$Device
    [int]$Port = 443
    [string]$ApiKey
    [string]$Protocol = "https"

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

    [Xml] invokeConfigQuery([string]$xPath,[string]$action) {
        $url = $this.getApiUrl() + "type=config&xpath=$xPath&action=show"
        $result = Invoke-WebRequest -Uri $url -SkipCertificateCheck
        $result = [xml]($result.Content)
        return $result
    }

}