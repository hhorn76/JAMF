#!/usr/bin/python
# Written by Heiko Horn 2019.02.08
# Chcks if the Lightspeed User Agent has been installed.

import os

result = 'FALSE'
strFile = '/usr/local/bin/useragent'
if os.path.exists(strFile):
	result = 'TRUE'
	
print '<result>' + result + '</result>'