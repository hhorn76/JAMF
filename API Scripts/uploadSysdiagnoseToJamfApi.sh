#!/bin/bash

# Jamf Pro API info
jamfUrl=$(/usr/bin/defaults read /Library/Preferences/com.jamfsoftware.jamf.plist jss_url)
# Base64 encoded username and password
# echo apiuser:password | base64
strEncoded=''

# Get the serial number from the device
strSerial=$(/usr/sbin/system_profiler SPHardwareDataType | /usr/bin/awk '/Serial/ {print $4}')

# Execute system diagnostic without UI and saving it to file.
echo 'Executing sysdiagnose binary and saving it to file.'
/usr/bin/sysdiagnose -ruf /tmp/
# Locate files that were generated by sysdiagnose
strTemp=$(/bin/ls /tmp/sysdiagnose*)

echo "Serialnumber: ${strSerial}"
intId=$(/usr/bin/curl -sk -H "authorization: Basic ${strEncoded}" ${jamfUrl}/JSSResource/computers/serialnumber/${strSerial} | xmllint --xpath '/computer/general/id/text()' -)

for file in ${strTemp}; do
if [ -f ${file} ]; then
echo "Uploading file: ${file}"
/usr/bin/curl -ks -H "authorization: Basic ${strEncoded}" ${jamfUrl}/JSSResource/fileuploads/computers/id/$intId -F name=@${file} -X POST
echo "Deleting file: ${file}"
rm ${file}
fi
done
