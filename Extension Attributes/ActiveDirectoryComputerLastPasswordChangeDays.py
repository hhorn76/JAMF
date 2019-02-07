#!/bin/bash 
# Writen By Heiko 2019.02.07

from datetime import datetime
import subprocess

domainName = subprocess.check_output( 'dscl \'/Active Directory/\' read . SubNodes | awk \'{print $2}\'', shell=True).strip()
adpwTime = subprocess.check_output( '/usr/bin/security find-generic-password -s \'/Active Directory/' + domainName + '\' /Library/Keychains/System.keychain 2> /dev/null | grep mdat | awk \'{print substr($2, 2, length($2)-7)}\'', shell=True).strip()

if adpwTime > 0:	
	d1 = int (datetime.now().strftime("%s"))
	d2 = int (datetime.strptime(adpwTime, "%Y%m%d%H%M%S").strftime("%s"))
	result =  int ((d1 - d2) / 86400)
	#print str (d1) + ' - ' + str (d2) + ' / 86400 = ' + str (result)
else:
	result = '9999'
	
print '<result>' + str (result) + '</result>'

