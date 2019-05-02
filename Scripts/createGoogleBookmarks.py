#!/usr/bin/python
## Written by Heiko Horn 2019.04.01
## This script will create a JSON file from a list of descriptions and URLs

####################################################################################
## Script arguments:
## $4: username as string
## $4: <username> "optional"
## $5: school section bookmark list
## $5: <js><ms><srs> "optional"

import json, hashlib, os, pwd, grp, sys
from SystemConfiguration import SCDynamicStoreCopyConsoleUser

####################################################################################
# Please add the Bookmarks you would like to add here: <name>,<url>
strDefault = """\
Google,https://google.com
Microsoft,https://miscrosoft.com
Apple,https://apple.com
Yahoo,https://yahoo.com
Bing,https://bing.com
Office365/OneDrive,https://mismunich-my.sharepoint.com
"""
# Please add the bookmarks for the junior school here: <name>,<url>
strJS = """\
Google,https://google.com
"""
# Please add the bookmarks for the middle school here: <name>,<url>
strMS = """\
Google,https://google.com
"""
# Please add the bookmarks for the senior school here: <name>,<url>
strSrS = """\
Google,https://google.com
"""

####################################################################################
# check if argument $4 was passed to the script to set the location of the JSON bookmarks file
print ('')
i=0
try:
	strUser = sys.argv[4]
	print ('User: ' + strUser)
	strFile='/Users/' + strUser + '/Library/Application Support/Google/Chrome/Default/Bookmarks'
	uid = pwd.getpwnam(strUser).pw_uid
except IndexError:
	currentUser = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]
	currentUser = [currentUser,""][currentUser in [u"loginwindow", None, u""]]
	print ('Current user: ' + currentUser)
	strFile='/Users/' + currentUser + '/Library/Application Support/Google/Chrome/Default/Bookmarks'
	uid = pwd.getpwnam(currentUser).pw_uid

gid = grp.getgrnam('staff').gr_gid

####################################################################################
# check if argument $4 was passed to the script to set the bookmark items in the JSON file
try:
	getdata = sys.argv[5]
	if sys.argv[5] == 'js':
		strList = strJS
		print ('Bookmarks list: Junior School')
	elif sys.argv[5] == 'ms':
		print ('Bookmarks list: Middle School')
		strList = strMS
	elif sys.argv[5] == 'srs':
		print ('Bookmarks list: Senior School')
		strList = strSrS
	else:
		strList = strDefault
		print ('Bookmarks list: Default')
except IndexError:
	strList = strDefault
	print ('Bookmarks list: Default')

####################################################################################
# create a python class objects for the child nodes 
class objChild:
	def __init__(self, name=None, url=None, id=None):
		self.name = name
		self.url = url
		self.type = 'url'
		self.id = id
		
# create a python class objects for the root node 
class objRoot(object):
	def __init__(self, d):
		for a, b in d.items():
			if isinstance(b, (list, tuple)):
				setattr(self, a, [objRoot(x) if isinstance(x, dict) else x for x in b])
			else:
				setattr(self, a, objRoot(b) if isinstance(b, dict) else b)

# function to create checksum from the items that were added
def checksum_bookmarks(bookmarks):
	roots = ['bookmark_bar', 'other', 'synced']
	md5 = hashlib.md5()
	def checksum_node(node):
		md5.update(node['id'].encode())
		md5.update(node['name'].encode('utf-16le'))
		if node['type'] == 'url':
			md5.update(b'url')
			md5.update(node['url'].encode())
		else:
			md5.update(b'folder')
			if 'children' in node:
				for c in node['children']:
					checksum_node(c)
	for root in roots:
		checksum_node(bookmarks['roots'][root])
	return md5.hexdigest()

# create a list of python child class objects
print ('Creating JSON child List.')
listChild = []
for lines in strList.splitlines():
		arrline = lines.split(',')
		listChild.append(objChild(arrline[0], arrline[1], str(i)))
		i+=1

# create a python root class objects
d = {'checksum': "", 'roots': { 'bookmark_bar': { "children": listChild, 'id': "1", 'name': "Bookmarks Bar", 'type': "folder" }, 'other': { 'children': [ ], 'id': "2", 'name': "Other Bookmarks", 'type': "folder" }, 'synced': { 'children': [ ], 'id': "3", 'name': "Mobile Bookmarks", 'type': "folder" } }, 'version': 1 }
x = objRoot(d)

#create a json string from the python root object
print ('Creating JSON root object.')
strJson = json.dumps(x, default=lambda x: x.__dict__, sort_keys=True)
#print strJson

# get checksum for bookmark items and add checksum to python object
checksum = checksum_bookmarks(json.loads(strJson))
x.checksum = checksum
print ('Adding Checksum to JSON.')
#print checksum

# delete old Bookmarks file if it exists, otherwise cretate the folder structure.
if os.path.exists(strFile):
	print ('Deleting Bookmarks a file.')
	os.remove(strFile) 
else:
	print ('Creating Bookmarks folders.')
	os.makedirs(strFile.replace('/Bookmarks', ''))
	os.chown(strFile.replace('Default/Bookmarks', ''), uid, gid)
	os.chown(strFile.replace('Chrome/Default/Bookmarks', ''), uid, gid)

# write the json object to a file.
print ('Writing JSON object to a file.')
jsonFile = open(strFile, 'w')
jsonFile.write(json.dumps(json.loads(json.dumps(x, default=lambda x: x.__dict__)), indent=4, sort_keys=True))
jsonFile.close()

# changing file ownership.
print ('Changing file ownership.')
os.chown(strFile, uid, gid)