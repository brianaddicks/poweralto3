class HelperRegex {
    static [string]$Ipv4 = '\b((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b'
    static [string]$Fqdn = '(?=^.{1,254}$)(^(?:(?!\d|-)[a-zA-Z0-9\-]{1,63}(?<!-)\.?)+(?:[a-zA-Z]{2,})$)'

    # function for checking regular expressions
    hidden [string] checkRegex($matchString,$regexString,$errorMessage) {
        $regex = [regex]$regexString
        if ($regex.Match($matchString).Success) {
            return $matchString
        } else {
            Throw $errorMessage
        }
    }

    # Ipv4 Address
    [string] isIpv4([string]$matchString, [string]$errorMessage) {
        $regexString  = $this::Ipv4
        return $this.checkRegex($matchString,$regexString,$errorMessage)
    }

    # Fqdn
    [string] isFqdn([string]$matchString, [string]$errorMessage) {
        #$errorMessage = "Value is not a valid FQDN."
        $regexString  = $this::Fqdn
        return $this.checkRegex($matchString,$regexString,$errorMessage)
    }

    # Fqdn or Ipv4 Address
    [string] isFqdnOrIpv4([string]$matchString, [string]$errorMessage) {
        #$errorMessage = "Value is not a valid FQDN or IPv4 Address."
        $regexString  = $this::Ipv4 + "|" + $this::Fqdn
        return $this.checkRegex($matchString,$regexString,$errorMessage)
    }

    # Constructor
    HelperRegex () {
    }
}

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