# poweralto3
PowerShell Module for Palo Alto firewalls.

This module is still in the early development phase.  For a functioning module please see poweralto2.

https://github.com/brianaddicks/poweralto2


## Known Issues
* Powershell Core will give you trouble when trying to use -SkipCertificateCheck for Invoke-RestMethod. See [here](https://github.com/PowerShell/PowerShell/issues/2211) for more details. Use the following command to fix for MacOS/OSX.
    brew install curl --with-openssl
