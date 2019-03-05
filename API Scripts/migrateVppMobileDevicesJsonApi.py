#!/usr/bin/python

import urllib2, json, plistlib

strJamfUrl = plistlib.readPlist('/Library/Preferences/com.jamfsoftware.jamf.plist')['jss_url'] + '/JSSResource'
#strJamfUrl = 'https://xxx.xxx.xxx:8443/JSSResource'
strApiUrl = strJamfUrl + '/mobiledeviceapplications'
base64Auth=''

request = urllib2.Request(strApiUrl)
request.add_header('Authorization', 'Basic ' + base64Auth)
request.add_header('Accept', 'application/json')

objJson=json.loads(urllib2.urlopen(request).read())
for item in objJson['mobile_device_applications']:
	intId=item['id']
	strName=item['name']
	strApiUrlApp=strApiUrl + '/id/' + str (intId)
	appRequest=urllib2.Request(strApiUrlApp)
	appRequest.add_header('Authorization', 'Basic ' + base64Auth)
	appRequest.add_header('Accept', 'application/json')
	objJsonApp=json.loads(urllib2.urlopen(appRequest).read())
	if objJsonApp['mobile_device_application']['vpp']['vpp_admin_account_id'] == 1:
		print ('ID: ' + str (intId))
		print ('Name: ' + strName)
		print ('Vpp account Id: ' + str (objJsonApp['mobile_device_application']['vpp']['vpp_admin_account_id']))
		print ('Tolal licenses: ' + str (objJsonApp['mobile_device_application']['vpp']['total_vpp_licenses']))
		print ('Used licenses: ' + str (objJsonApp['mobile_device_application']['vpp']['used_vpp_licenses']))
		print ('Free: ' + str (objJsonApp['mobile_device_application']['general']['free']))
		print ('')