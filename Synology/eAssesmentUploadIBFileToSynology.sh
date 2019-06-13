#!/bin/bash
# Written by Heiko 2019-01-28

########################################
#Get variables from Jamf Policy
strUsername="$4"
strPassword="$5"
strFileServer="$6"
strShare="$7"

#Set the Internal Field Separator to handle space characters
IFS=$'\n'

########################################
#Calculate current school year
intYear=$(date +%Y)
intMonth=$(date +%m) 
if [ $intMonth -lt 7 ]; then
	schoolYear="$((intYear - 1))-$intYear"
else
	schoolYear="$intYear-$((intYear + 1))"
fi
########################################
### log in to synology filestaitiom and get session sid
function synologyLogin {
	strFileServerApi=${strFileServer}'/webapi/auth.cgi?api=SYNO.API.Auth&version=3&method=login&account='$strUsername'&passwd='$strPassword'&session=FileStation'
	strSID=$(curl $strFileServerApi --silent | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["data"]["sid"];')
	echo "Your session id is: "$strSID
}
########################################
## list FilseStation files in folder path
function synologyListFiles {
	strFileServerApi=${strFileServer}'/webapi/entry.cgi?api=SYNO.FileStation.List&version=2&method=list&_sid='$strSID'&folder_path=/'$1
	curl $strFileServerApi --silent # | perl -pe 's/[^[:ascii:]]+//g'
	intCount=0
arrJson=$(curl $strFileServerApi --silent | perl -pe 's/[^[:ascii:]]+//g' | /usr/bin/python -c 'import json,sys; obj=json.load(sys.stdin);
for file in obj["data"]["files"]: 
	if file["isdir"] == 'False': print file["name"]')
		
	for strFiles in ${arrJson}; do
		echo $strFiles
		intCount=$(expr $intCount + 1)
	done	
	echo "Files in Folder: $intCount"
}
########################################
### upload file to Filestation
function synologyUploadFile {
	strFileServerApi=${strFileServer}'/webapi/entry.cgi?api=SYNO.FileStation.Upload&version=2&method=upload&_sid='$strSID

echo "Copying file: $1
from: $2
to network location: $3
overwrite: $4
create parent: $5"

	strStatus=$(curl $strFileServerApi \
	-H "Content-Type: multipart/form-data" \
	-F "api=SYNO.FileStation.Upload" \
	-F "version=2" \
	-F "method=upload" \
	-F "overwrite=${4}" \
	-F "path=/${3}" \
	-F "create_parents=${5}" \
	-F "_sid=${strSID}" \
	-F "file=@\"${2}${1}\";filename=\"${1}\"" \
	--silent | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["success"];')
	echo "File upload was successful: "$strStatus
}
########################################
### log out of synology filestaitiom
function synologyLogout {
	strFileServerApi=${strFileServer}'/webapi/auth.cgi?api=SYNO.API.Auth&version=1&method=logout&session=FileStation&_sid='$strSID
	strLogout=$(curl $strFileServerApi --silent | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["success"];')
	echo "Logged out of Filestation successful: "$strLogout
}
########################################
### get creation date of file 
function getFileCreationDate {
	strDate=$(stat -f "%B" $1)
	date -j -u -f "%s" $strDate +'%Y-%m-%d'
}

########################################
synologyLogin
echo ''
arrResponse=()
arrResponse+=$( find /Users -ignore_readdir_race -maxdepth 4 -name '*.ibresponse' -exec echo {} 2> /dev/null \; )

strCurrentDate=""
intCountLocal=0
for strResponse in $arrResponse; do
	intCountLocal=$(expr $intCountLocal + 1)
	strDate=$(getFileCreationDate $strResponse)
	if [ "$strDate" != "$strCurrentDate" ]; then
		strNetworkPath="$strShare/$schoolYear/$strDate"
		#arrFiles=$(synologyListFiles "$strNetworkPath")
	fi
	strFileName=$(basename $strResponse)
#	if [[ ! "${arrFiles[@]}" =~ "${strFileName}" ]]; then
		strFilePath="${strResponse/$strFileName}"
		synologyUploadFile $strFileName $strFilePath "$strNetworkPath" "true" "true"
		echo ''
		if [ $strStatus = "True" ];	then
			echo "Deleting file:$strFileName from location: $strFilePath"
			rm $strFilePath$strFileName
		else
			echo "Could not upload response $strFilePath$strFileName to location: $strNetworkPath"
			echo ''
			echo "Files on network folder: $intCountLocal"
			echo ''
			exit 1
		fi
		echo ''
#	else 
#		echo"There are no files to upload..."
#	fi
	strCurrentDate=$strDate
done
echo "Files in /Users folder: $intCountLocal"
echo ''
synologyLogout
############################################