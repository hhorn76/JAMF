#!/usr/bin/python
# written by Heiko 17.01.2018

#import modules
from SystemConfiguration import SCDynamicStoreCopyConsoleUser
from datetime import datetime
import os, time, subprocess
#import time, subprocess

#define log variable
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
appList.append(objApp("Google Chrome", "installGoogleChrome", ""))
appList.append(objApp("VLC media player", "installVLC", ""))
appList.append(objApp("Microsoft Skype","installSkype", ""))
appList.append(objApp("Microsoft OneDrive", "installOneDrive", ""))
appList.append(objApp("Microsoft Office", "installOffice", ""))
appList.append(objApp("Apple Software Updates", "updateOS", ""))
	
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
	subprocess.call('/usr/local/bin/jamf policy -forceNoRecon -event ' + trigger, shell=True)
	if subprocess.CalledProcessError:
		print "Something went wrong with trigger: " + trigger
		if i.package:
			print 'failed ghost package installation: '+i.package
			ghostPackage(i.name, 'Failed', i.package)

#function to check if process is running
def is_running(process):
	stat = subprocess.call('pgrep ' + process, shell=True)
	return stat == 0

#function to quit SplashBuddy
def killProcess(process):
	subprocess.call('pkill '+ process, shell=True)

#get current logged-in user
currentUser = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]
currentUser = [currentUser,""][currentUser in [u"loginwindow", None, u""]]

#for each class object in list execute jamf event
for i in appList:
	print 'Name: ' + i.name + '\nTrigger: ' + i.trigger + '\nPackage: ' + i.package
	if i.package:
		print 'starting ghost package installation: '+i.package
		ghostPackage(i.name, 'Start', i.package)
		print 'calling jamf event trigger: '+i.trigger
		installApp(i.trigger)
		print 'finishing ghost package installation: '+i.package
		ghostPackage(i.name, 'Stop', i.package)
		print ''
	else:
		print 'calling jamf event trigger: '+i.trigger
		installApp(i.trigger)
		print ''

#wait until SplashBuddy has been quit or quit after 5 minutes.
processName = 'SplashBuddy'
sleepTime = 300
while is_running(processName):
	for i in range(sleepTime+1):
		print i
		time.sleep(1)
    	if i == sleepTime:
			print processName+' process has been running for 5 minutes, quitting '+ processName+' now.'
			killProcess(processName)
			break

#uninstalls SplashBuddy
print 'SplashBuddy.app has quit, uninstalling SplashBuddy.'
os.remove('/Library/Application Support/SplashBuddy')
os.remove('/Library/Preferences/io.fti.SplashBuddy.plist')
subprocess.call('launchctl disable io.fti.SplashBuddy.launch', shell=True)
subprocess.call('pkgutil --forget "io.fti.SplashBuddy.Installer', shell=True)
os.remove('/Library/LaunchAgents/io.fti.SplashBuddy.launch.plist')
os.remove('/Users/'+currentUser+'/Library/Containers/io.fti.SplashBuddy/Data/Library/.SplashBuddyDone')