#!/bin/bash
ls
currentUser=$( /usr/bin/last -1 -t console | awk '{print $1}' )
logFile="/var/log/jamf.log"
IFS=$'\n'

ARRAY=()
ARRAY+=("Rename":"renameMac":"RenameMac")
ARRAY+=("BindAD":"rebindAD":"BindAD")
ARRAY+=('Printers':'installPrinters':'Printers')
ARRAY+=('Sophos Antivirus':'installSophosHTTPS':'SophosEnterprise')
ARRAY+=('Google Chrome':'installGoogleChrome':'')
ARRAY+=('VLC media player':'installVLC':'')
ARRAY+=('Microsoft Skype':'installSkype':'')
ARRAY+=('Microsoft OneDrive':'installOneDrive':'')
ARRAY+=('Microsoft Office':'installOffice':'Microsoft_Office')
ARRAY+=('Apple Software Updates':'updateOS':'OSUpdate')

# Quit SplashBuddy if still running
function killProcess {
	if [[ $(pgrep $1) ]]; then
		launchctl unload /Library/LaunchAgents/io.fti.SplashBuddy.launch.plist
		pkill $1
	fi	
}

#write log information to jamf pro log to simulate a ghost installation
function ghostPackage {
	forceDate=$(date)
	forceUser="ghostNshell"
	forcePackage="${3}"'-1.2.3.pkg'
	if [[ "${2}" = 'Start' ]]; then
		forceStatus='Installing'
	elif [[ "${2}" =  'Failed' ]]; then
		forceStatus="Installation failed. The installer reported: installer: Package name is"
	else
		forceStatus="Successfully installed"
	fi
	echo "$forceDate $forceUser: $forceStatus $forcePackage..." 
	#write log information to log file
	echo "$forceDate $forceUser: $forceStatus $forcePackage..." >> $logFile
	echo "$forcePackage -> $forceStatus"
}

# Install Applications from Array
function installApp {
	echo "Installing $1 with jamf policy event: $2"
	/usr/local/bin/jamf policy -forceNoRecon -event $2
	if [ $? > 0 ]; then
		ghostPackage "${app}" 'Failed' "${package}"
		echo ''
		continue
	fi
}

for items in ${ARRAY[@]}; do
	IFS=$':' read -r app trigger package <<< "$items"
	echo "Application Name: ${app}"
	echo "Trigger: ${trigger}"
	echo "Package: ${package}"
	if  [ ! -z "${package}" ]; then
		echo "starting ghost package installation: ${package}"
		ghostPackage "${app}" 'Start' "${package}" 
		echo "calling jamf event trigger: ${trigger}"
		installApp "${app}" "${trigger}"
		echo "finishing ghost package installation: ${package}"
		ghostPackage "${app}" 'Stop' "${package}" 
		echo ''
	else
		echo "calling jamf event trigger: ${trigger}"
		installApp "${app}" "${trigger}"
		echo ''
	fi
done
#submit invetory update to jamf pro
echo 'submit invetory update to jamf pro'
ghostPackage 'Jamf_Recon' 'Start' 'Recon'
/usr/local/bin/jamf recon
ghostPackage 'Jamf_Recon' 'Stop' 'Recon'

processName='SplashBuddy'
sleepTime=300
splashDone="/Users/$currentUser/Library/Containers/io.fti.SplashBuddy/Data/Library/.SplashBuddyDone"
for i in  $(seq 1 $sleepTime); do 
	if [[ -f $splashDone ]]; then
		break
	else
		if (( $i % 10 == 0 )); then
			echo "Restarting in $(($sleepTime - $i)) seconds."
		fi
		sleep 1
		if [ $i = $sleepTime ]; then
			echo "$processName process has been running for 5 minutes, quitting $processName now."
			killProcess $processName
		fi
	fi
done

#kill SplashBuddy process
echo ''
echo "Killing running $processName process."
killProcess $processName
echo ''
#uninstall SplashBuddy
echo "$processName has quit, uninstalling $processName."
echo ''
# we are done, so delete SplashBuddy
#chmod -Rf 777 /Library/Application\ Support/$processName/
rm -rf /Library/Application\ Support/$processName/
pkgutil --forget io.fti.$processName.Installer
rm -f /Library/Preferences/io.fti.$processName.plist
rm -f /Library/LaunchAgents/io.fti.$processName.launch.plist
rm /Users/$currentUser/Library/Containers/io.fti.$processName/Data/Library/.SplashBuddyDone
