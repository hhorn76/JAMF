#!/bin/bash
# Written by Heiko Horn on 2019.02.22
# This script migrates the moblile device application VPP token id, it can be used to migrate all applications from the egacy vpp to the new apps and books.

# API service account credentials
jamfUrl=$( defaults read /Library/Preferences/com.jamfsoftware.jamf.plist jss_url ) 
# Base64 encoded username and password
# echo apiuser:password | base64
strAuth=''

# XML sring to set the new vpp_admin_account_id to (Please modify to your need)
strXml='<mobile_device_application><vpp><vpp_admin_account_id>3</vpp_admin_account_id></vpp></mobile_device_application>'

# collect all application id's in an array
arrID=$( curl -sk -H "authorization: Basic ${strAuth}" -H 'Accept: application/xml' ${jamfUrl}/JSSResource/mobiledeviceapplications | xmllint -xpath /mobile_device_applications/mobile_device_application/id - | sed -e 's/<[^>]*>/ /g' )

for app in ${arrID[@]}; do
# get the vpp id currently assigned
intVpp=$( curl -sk -H "authorization: Basic ${strAuth}" -H 'Accept: application/xml' ${jamfUrl}/JSSResource/mobiledeviceapplications/id/${app}/subset/VPP | xmllint -xpath /mobile_device_application/vpp/vpp_admin_account_id - | sed -e 's/<[^>]*>//g' )

if [ ${intVpp} -eq 1 ]; then
echo -n Updating application ID: ${app}
# set the new vpp_admin_account_id with the specified xml string
strError=$( curl -sk -H "authorization: Basic ${strAuth}" "${jamfUrl}/JSSResource/mobiledeviceapplications/id/${app}" -X PUT -H Content-type:application/xml --data $strXml | grep Error )
echo ''
if [[ -z ${strError} ]]; then
echo "Successfully updated application with id: ${app}"
intCount=$(( intCount + 1 ))
else
echo ${strError} | sed -e 's/<[^>]*>//g'
intCountError=$(( intCountError + 1 ))
fi
fi
echo ''
done

echo "Applications with errors: ${intCountError}"
echo "Applications successfully updated: ${intCount}"
