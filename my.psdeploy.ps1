Deploy Module {
    By PSGalleryModule {
        FromSource module
        To PSGallery
        WithOptions @{
            ApiKey = $global:nugetapikey
        }
    }
}