Deploy Module {
    By PSGalleryModule {
        FromSource MyModuleNameHere
        To PSGallery
        WithOptions @{
            ApiKey = $ENV:NugetApiKey
        }
    }
}