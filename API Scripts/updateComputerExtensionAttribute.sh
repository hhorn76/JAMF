#!/bin/bash
# Written by Heiko Horn on 2019.06.13
# This script updates an extension attribute for a computer object.

# Jamf Pro API variables
jamfUrl=$( defaults read /Library/Preferences/com.jamfsoftware.jamf.plist jss_url ) 
strAuth="${4}"
eaValue=${5}
eaName=${6}

# Get serial number of the current computer
serialNumber=$( ioreg -c IOPlatformExpertDevice -d 2 | awk -F\" '/IOPlatformSerialNumber/{print $(NF-1)}' )

# Get thew ID of the Extension Attribute specified by name
eaID=$( curl -sk -H "authorization: Basic ${strAuth}" -H 'Accept: application/xml' ${jamfUrl}JSSResource/computerextensionattributes/name/${eaName} | xmllint -xpath /computer_extension_attribute/id - | sed -e 's/<[^>]*>//g' )

# Get thew ID of the computer in jamf by serialnumber
compID=$( curl -sk -H "authorization: Basic ${strAuth}" -H 'Accept: application/xml' ${jamfUrl}JSSResource/computers/serialnumber/${serialNumber} | xmllint -xpath /computer/general/id - | sed -e 's/<[^>]*>//g'  )

# The XML for setting the value of the Extension Attribute
strXml="
<computer>
	<extension_attributes>
		<extension_attribute>
			<id>${eaID}</id>
			<type>Number</type>
			<value>${eaValue}</value>
		</extension_attribute>
	</extension_attributes>
</computer>"

# Set the value of the Extension Attribute
if [[ ! -z ${compID} ]]; then
	strError=$( curl -sk -H "authorization: Basic ${strAuth}" "${jamfUrl}JSSResource/computers/id/${compID}" -X PUT -H Content-type:application/xml --data "${strXml}" | grep Error )
	
	# Check if an error occoured while posting the xml
	if [[ -z ${strError} ]]; then
		echo "Successfully updated Extension Attribute: ${eaName} for serialnumber: ${serialNumber} with value ${eaValue}."
	else
		echo ${strError} | sed -e 's/<[^>]*>//g'
	fi
else 
	echo "Error: computer with serial number ${serialNumber} is not in Jamf Pro."
fi