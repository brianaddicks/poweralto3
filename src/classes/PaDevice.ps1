
class PaDevice {
    [string]$Device
    [int]$Port = 443
    [string]$ApiKey
    [string]$Protocol = "https"

    # Constructor
    PaDevice ([string]$Device) {
        $helperRegex = [HelperRegex]::new()
        $this.Device  = $helperRegex.isFqdnOrIpv4($Device,"Device must be a valid FQDN or IPv4 Address.")
    }

    [String] getApiUrl() {
        if ($this.Device) {
            $url = $this.Protocol + "://" + $this.Device + ":" + $this.Port + "/api/"
            return $url
        } else {
            return $null
        }
    }

}