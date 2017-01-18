class PaDevice {
    [string]$Device
    [int]$Port = 443
    [string]$ApiKey
    [string]$Protocol = "https"

    # Constructor
    PaDevice () {
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
<#

        public string ApiUrl {
            get {
                if ( !string.IsNullOrEmpty( this.Protocol ) && !string.IsNullOrEmpty( this.Device ) && this.Port > 0 ) {
                    return this.Protocol + "://" + this.Device + ":" + this.Port + "/api/";
                } else {
                    return null;
                }
            }
        }
#>