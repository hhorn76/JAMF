#!/usr/bin/python
# Written by Heiko 2019.02.07
# Checks if a computer is on premises by pinging the domain controllers

import subprocess

def ping(host):
	ret = subprocess.call(['ping', '-c', '2', '-o', host], stdout=open('/dev/null', 'w'), stderr=open('/dev/null', 'w'))
	return ret == 0

dnsDomain = subprocess.check_output( 'dsconfigad -show | awk \'/Active Directory Domain/{print $NF}\'', shell=True).strip()

if ping (dnsDomain):
	result='TRUE'
else:
	result='FALSE'
	
print '<result>' + result + '</result>'