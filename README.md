# poweralto3
PowerShell Module for Palo Alto firewalls.

This module is still in the early development phase.  For a functioning module please see poweralto2.

https://github.com/brianaddicks/poweralto2

## Installation


#### The Easy Way

```powershell
# Requires WMF5, but so does this module.
Install-Module PowerAlto3
```

#### The Not-So-Easy Way

```powershell
# Runs install.ps1 from this repo.

# Downloads to PSModulePath if it exists, otherwise goes to current directory
Invoke-Expression (((Invoke-WebRequest -Uri "https://git.io/pa3install").Content) + ';DownloadPowerAlto3')

# Downloads to desired Path (replace 'YOURPATH').
Invoke-Expression (((Invoke-WebRequest -Uri "https://git.io/pa3install").Content) + ';DownloadPowerAlto3 -Destination YOURPATH')


```

#### The Harder-But-Still-Pretty-Easy Way
Click that green button near the top right of your browser and pick your poison.


## Known Issues

* Powershell Core will give you trouble when trying to use -SkipCertificateCheck for Invoke-RestMethod. See [here](https://github.com/PowerShell/PowerShell/issues/2211) for more deatils. Use the following command to fix for MacOS/OSX.

    brew install curl --with-openssl
