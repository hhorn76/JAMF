#!/bin/bash
# Extensions Atrribute: Find all appstore apps on this mac
# lists all apps from the apps store
# written by Heiko Horn 2020-04-16

# initialise a array list
arrAppStoreApps=()
# search the metadata for apps that were installed from the app store
arrAppStoreApps=$(mdfind "kMDItemAppStoreHasReceipt=1")
# sort the array list
sorted=$(printf '%s\n' "${arrAppStoreApps[@]}"|sort)

echo "<result>${sorted}</result>"