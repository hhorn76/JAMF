#!/bin/bash
# Written by Heiko 2018.10.19
# Gets the current organizational unit that the computer is bound to in active directory

# Please modify the following value to your needs: #DOMAIN#

#Get computername
CompName=$(dsconfigad -show | awk '/Computer Account/{print $NF}' | sed 's/$$//')

#Get OU for computer
OU=$(dscl "/Active Directory/#DOMAIN#/All Domains" read /Computers/${CompName}$ dsAttrTypeNative:distinguishedName | tail -1 | awk -F"${CompName}," '{print $2}')

echo "<result>$OU</result>"