class PaDevice {
    [string]$Device
    [int]$Port
    [string]$ApiKey
    [string]$Protocol

    # Constructor
    PaDevice () {
    }

    [String] getApiUrl() {
        switch ($this.Protocol) {
            "http"  { }
            default { $this.Protocol = "https" }
        }

        $url = $this.Protocol + "://"
        return $url
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