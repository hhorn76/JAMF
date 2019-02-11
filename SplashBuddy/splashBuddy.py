#!/usr/bin/python
# written by Heiko 17.01.2018

#import modules
from SystemConfiguration import SCDynamicStoreCopyConsoleUser
from datetime import datetime
import os, time, subprocess
#import time, subprocess

#define log variable
global errorFlag
logFile = "/var/log/jamf.log"

#create class object 
class objApp:
	def __init__(self, name, trigger, package):
		self.name = name
		self.trigger = trigger
		self.package = package

#create an empty list
appList = []
#add class objects to list
appList.append(objApp("Rename", "renameMac", "RenameMac"))
appList.append(objApp("BindAD", "rebindAD", "BindAD"))
appList.append(objApp("Printers", "installPrinters", "Printers"))
appList.append(objApp("Sophos Antivirus", "InstallSophosHTTPS", "SophosEnterprise"))
appList.append(objApp("Google Chrome", "installGoogleChrome", "GoogleChrome"))
appList.append(objApp("VLC media player", "installVLC", "vlc"))
appList.append(objApp("Microsoft Skype","installSkype", "Skype"))
appList.append(objApp("Microsoft OneDrive", "installOneDrive", "OneDrive"))
appList.append(objApp("Microsoft Office", "installOffice", "Microsoft_Office"))
appList.append(objApp("Apple Software Updates", "updateOS", "OSUpdate"))
	
#define functions
#write log information to jamf pro log to simulate a ghost installation
def ghostPackage(name, status, package):
	if status == 'Start':
		forceStatus='Installing'
	elif status == 'Failed':
		forceStatus="Installation failed. The installer reported: installer: Package name is"
	else:
		forceStatus="Successfully installed"

	now=datetime.now()
	forceDate=now.strftime("%c")
	forceUser="ghostNshell"
	forcePackage=package+'-1.2.3.pkg'
	#print forceDate, forceUser, forceStatus, forcePackage
	#write log information to log file
	f = open(logFile, "a")
	f.write(forceDate+' '+forceUser+': '+forceStatus+' '+forcePackage+'...\n')
	print forcePackage+' -> '+forceStatus

#execute jamf policy event
def installApp(trigger):
	p = subprocess.Popen('/usr/local/bin/jamf policy -forceNoRecon -event ' + trigger, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
	(output, err) = p.communicate()
	## Wait for date to terminate. Get return returncode ##
	p_status = p.wait()
	print "Command error : ", err
	#subprocess.call('/usr/local/bin/jamf policy -forceNoRecon -event ' + trigger, shell=True)
	if p_status != 0:
		if i.package:
			print 'failed ghost package installation: '+i.package
			ghostPackage(i.name, 'Failed', i.package)
			global errorFlag
			errorFlag = 1

#function to quit SplashBuddy
def killProcess(process):
	subprocess.call('launchctl unload io.fti.SplashBuddy.launch', shell=True)
	subprocess.call('pkill '+ process, shell=True)

#get current logged-in user
currentUser = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]
currentUser = [currentUser,""][currentUser in [u"loginwindow", None, u""]]
print('Current user: '+currentUser)
print('')

#for each class object in list execute jamf event
for i in appList:
	errorFlag = 0
	print 'Name: ' + i.name + '\nTrigger: ' + i.trigger + '\nPackage: ' + i.package
	if i.package:
		print 'starting ghost package installation: '+i.package
		ghostPackage(i.name, 'Start', i.package)
		print 'calling jamf event trigger: '+i.trigger
		installApp(i.trigger)
		if errorFlag == 0:
			print 'finishing ghost package installation: '+i.package
			ghostPackage(i.name, 'Stop', i.package)
			print ''
	else:
		print 'calling jamf event trigger: '+i.trigger
		installApp(i.trigger)
		print ''

#submit invetory update to jamf pro
ghostPackage('Jamf Recon', 'Start', 'Recon')
subprocess.call('/usr/local/bin/jamf recon', shell=True)
ghostPackage('Jamf Recon', 'Stop', 'Recon')

#wait until SplashBuddy has been quit or quit after 5 minutes.
processName = 'SplashBuddy'
sleepTime = 300
splashDone = '/Users/'+currentUser+'/Library/Containers/io.fti.SplashBuddy/Data/Library/.SplashBuddyDone'
for i in range(sleepTime+1):
	if os.path.exists(splashDone):
		break
	if i % 10 == 0:
		print 'Restarting in ' + str(sleepTime - i) + ' seconds.'
	time.sleep(1)
	if i == sleepTime:
		print processName+' process has been running for 5 minutes, quitting '+ processName+' now.'
		killProcess(processName)

#kill SplashBuddy process
print ''
print 'Killing running Splashbuddy process.'
killProcess(processName)
print ''

#uninstall SplashBuddy
print processName+' has quit, uninstalling SplashBuddy.'
print ''

processList = []
#processList.append('pkgutil --forget "io.fti.SplashBuddy.Installer')
processList.append('launchctl unload /Library/LaunchAgents/io.fti.SplashBuddy.launch.plist')
processList.append('rm -rf /Library/Application Support/SplashBuddy')

for strProcess in processList:
	print "Executing command: "+ strProcess
	subprocess.call(strProcess, shell=True)
print ''

appList = []
appList.append('/Library/Preferences/io.fti.SplashBuddy.plist')
appList.append('/Library/LaunchAgents/io.fti.SplashBuddy.launch.plist')
appList.append(splashDone)

for filePath in appList:
	if os.path.exists(filePath):
		print "Deleting file: "+ filePath
		os.remove(filePath)

subprocess.call('reboot', shell=True)