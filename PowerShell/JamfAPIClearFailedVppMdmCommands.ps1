# Written by Heiko Horn on 2019.08.12
# This script check all computer objects in Jamf to see if there are any failed MDM commands.

# API Variables 
$jamfUser='' # Add API username
$jamfPass='' # Add API password 
$strUrl="https://xxx.xxx.xxx:8443/JSSResource"

# Don't modify these variables
$strAuth=[Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $jamfUser,$jamfPass)))
$arrFailed=@()
$intCount=0
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Function to clear failed commands
function clearFailedMdmCommands ($id) {
    Invoke-RestMethod -Uri "$strUrl/commandflush/computers/id/$id/status/Failed" -Headers @{Authorization=("Basic {0}" -f $strAuth); "Accept"="application/xml"} -Method Delete
}

# Function to send blank push notification
function sendBlankPush () {
    Invoke-RestMethod -Uri "$strUrl/computercommands/command/BlankPush/id/$id" -Headers @{Authorization=("Basic {0}" -f $strAuth); "Accept"="application/xml"} -Method Post
}

# Function to get failed commands with device id
function getFailedMdmCommands ($id) {
    Invoke-RestMethod -Uri "$strUrl/computerhistory/id/$id" -Headers @{Authorization=("Basic {0}" -f $strAuth); "Accept"="application/xml"}
}

# Function to get all computers
function getAllComputers () {
    Invoke-RestMethod -Uri "$strUrl/computers" -Headers @{Authorization=("Basic {0}" -f $strAuth); "Accept"="application/xml"}
}

$objJamf=getAllComputers
foreach ($item in $objJamf.computers.computer) {
    $id=$item.id
    Write-Host "Getting failed commands for: $id"
    $objFailed=getFailedMdmCommands $id
    if ($objFailed.computer_history.commands.failed) {
        $objCommand=$objFailed.computer_history.commands.failed.command
        Write-Host "$($item.name) has failed commands."
        if ( ($objCommand.status).ForEach({$_.Contains('VPP')}) -eq $true ) {
            Write-Host "Removing failed MDM commands ..." -ForegroundColor Yellow
            #$objMDM=clearFailedMdmCommands $id
            Write-Host "Sending blank push notification ..." -ForegroundColor Yellow
            #$objPush=sendBlankPush $id
            $arrFailed+=$item
            $intCount+=1
            Write-Host "Computer name: $($item.name)" -ForegroundColor Yellow
            Write-Host "$($objCommand.issued)`n"
        } else {
            foreach ($failed in $objCommand.status) {
                Write-Host $failed -ForegroundColor Magenta
            }
            Write-Host ''
        }
    }
}

Write-Host "`nFound $intCount with failed VPP commands:"
if ($intCount -gt 0 ) {
    $arrFailed
}

