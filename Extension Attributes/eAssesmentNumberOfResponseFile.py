#!/usr/bin/python
#Written by Heiko 2019.02.07

import os
# create an empty list
listFiles = []
# find files in /Users with .ibresponse file extension
for root, dirs, files in os.walk("/Users"):
	for file in files:
		if file.endswith('.ibresponse'):
			listFiles.append(file)
			#print(os.path.join(root, file))
	
print ('<result>' + str (len(listFiles)) + '/result>')
