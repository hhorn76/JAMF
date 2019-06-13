#!/usr/bin/python
# Written by Heiko Horn 2019.06.10
# Gets the catalog URL for the softare update server

import plistlib, os

strPlist = '/Library/Preferences/com.apple.SoftwareUpdate.plist'
strKey = 'CatalogURL'
if os.path.isfile(strPlist):
	strSUSUrl = plistlib.readPlist(strPlist)[strKey]

print ('<result>' + strSUSUrl + '</result>')