class HelperRegex {
    static [string]$Ipv4 = '\b((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b'
    static [string]$Fqdn = '(?=^.{1,254}$)(^(?:(?!\d|-)[a-zA-Z0-9\-]{1,63}(?<!-)\.?)+(?:[a-zA-Z]{2,})$)'

    # function for checking regular expressions
    static [string] checkRegex($matchString,$regexString,$errorMessage) {
        $regex = [regex]$regexString
        if ($regex.Match($matchString).Success) {
            return $matchString
        } else {
            Throw $errorMessage
        }
    }

    # Ipv4 Address
    static [string] isIpv4([string]$matchString, [string]$errorMessage) {
        $regexString  = [HelperRegex]::Ipv4
        return [HelperRegex]::checkRegex($matchString,$regexString,$errorMessage)
    }

    # Fqdn
    static [string] isFqdn([string]$matchString, [string]$errorMessage) {
        $regexString  = [HelperRegex]::Fqdn
        return [HelperRegex]::checkRegex($matchString,$regexString,$errorMessage)
    }

    # Fqdn or Ipv4 Address
    static [string] isFqdnOrIpv4([string]$matchString, [string]$errorMessage) {
        $regexString  = [HelperRegex]::Ipv4 + "|" + [HelperRegex]::Fqdn
        return [HelperRegex]::checkRegex($matchString,$regexString,$errorMessage)
    }

    # Constructor
    HelperRegex () {
    }
}