#!/usr/bin/python
# Written by Heiko Horn on 2018.03.06
# This script get the vpp information for all mobile device applications in Jamf Pro using XML.

import urllib2, base64, plistlib
import xml.etree.ElementTree as ET

strJamfUrl = plistlib.readPlist('/Library/Preferences/com.jamfsoftware.jamf.plist')['jss_url'] + '/JSSResource'
#strJamfUrl = 'https://xxx.xxx.xxx:8443/JSSResource'
strApiUrl=strJamfUrl + '/mobiledeviceapplications'
base64Auth='='

request = urllib2.Request(strApiUrl)
request.add_header('Authorization', 'Basic ' + base64Auth)
request.add_header('Accept', 'application/xml')
result = urllib2.urlopen(request)

root = ET.fromstring(result.read())

for child in root:
	element = child.findall('./id')
	for i in element:
		intId = i.text
		strApiUrlApp = strApiUrl + '/id/' + str (intId)
		appRequest=urllib2.Request(strApiUrlApp)
		appRequest.add_header('Authorization', 'Basic ' + base64Auth)
		appRequest.add_header('Accept', 'application/xml')
		resultApp = urllib2.urlopen(appRequest)
		rootApp = ET.fromstring(resultApp.read())
		print ('ID: ' + intId)
		for name in rootApp.findall("./general/name"):
			print('Name: ' + name.text)
		for vppId in rootApp.findall("./vpp/vpp_admin_account_id"):
			print('Vpp account Id: ' + vppId.text)
		for vppTotal in rootApp.findall("./vpp/total_vpp_licenses"):
			print('Tolal licenses: ' + vppTotal.text)
		for vppUsed in rootApp.findall("./vpp/used_vpp_licenses"):
			print('Used licenses: ' + vppUsed.text)
		for vppFree in rootApp.findall("./general/free"):
			print('Free: ' + vppFree.text)	
		print ('')

		
