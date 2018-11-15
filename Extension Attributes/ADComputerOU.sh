#!/bin/bash
# Written by Heiko 2018.10.19
# Gets the current organizational unit that the computer is bound to in active directory

# Please modify the following value to your needs: #DOMAIN#

#Get computername and domain name
compName=$(dsconfigad -show | awk '/Computer Account/{print $NF}' | sed 's/$$//')
domainName=$(dscl "/Active Directory/" read . SubNodes | awk '{print $2}')
#Get OU for computer
OU=$(dscl "/Active Directory/$domainName/All Domains" read /Computers/${compName}$ dsAttrTypeNative:distinguishedName | tail -1 | awk -F"${compName}," '{print $2}')

echo "<result>$OU</result>"