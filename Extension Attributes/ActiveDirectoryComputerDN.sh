#!/bin/bash
# Written by Heiko 2018.10.19
# Gets the current distinguished name for a computer in active directory

#Get computername and domain name
computerName=$(dsconfigad -show | awk '/Computer Account/{print $NF}' | sed 's/$$//')
domainName=$(dscl "/Active Directory/" read . SubNodes | awk '{print $2}')
#Get DN for computer
distinguishedName=$(dscl "/Active Directory/${domainName}/All Domains" read /Computers/${computerName}$ dsAttrTypeNative:distinguishedName | tail -1 | awk -F"${computerName}," '{print $2}')
echo "<result>$distinguishedName</result>"
