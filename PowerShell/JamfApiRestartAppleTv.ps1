# Written by Heiko Horn on 2020.02.14
# This script will get all AppleTv objects in Jamf and send a managed command to restart them.
# To run this on a Mac you need to install PowerShell for macOS from https://github.com/PowerShell/PowerShell

# Common Variables
$arrFailed=@()
#$arrFailedDEP=@()
$intFailed=0
#$intFailedDEP=0
$intCount=0

# API Variables 
$jamfUser='' # Add API username
$jamfPass='' # Add API password 
$strUrl="https://xxx.xxx.xxx:8443/JSSResource"

# Don't modify these variables
$strAuth=[Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $jamfUser,$jamfPass)))
$arrFailed=@()
$intCount=0
# Enable SSL connection using TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Function to send restart managed command
function restartDevice () {
    Invoke-RestMethod -Uri "$strUrl/mobiledevicecommands/command/RestartDevice/id/$id" -Headers @{Authorization=("Basic {0}" -f $strAuth); "Accept"="application/xml"} -Method Post
}

# Function to get all computers
function getAllDevices () {
    Invoke-RestMethod -Uri "$strUrl/mobiledevices" -Headers @{Authorization=("Basic {0}" -f $strAuth); "Accept"="application/xml"}
}

# Get all mobile device objects in Jamf Pro
$objJamf=getAllDevices
foreach ($item in $objJamf.mobile_devices.mobile_device) {
    if (($item.model_identifier -like 'AppleTV*') -and ($item.supervised -eq 'true')) {
        $id=$item.id
        #Write-Host "INFO - Restarting Apple TV's...`n"
        $objRestart=restartDevice $id
        $strStatus=$objRestart.mobile_device_command.mobile_devices.mobile_device.status
        Write-Host "Name: $($item.name) `nID: $id`nStatus: $($strStatus)`n"
        if ($strStatus -ne 'Command sent') {
            Write-Host "WARNING - Failed to restart device..."
            $intFailed+=1
        }
        $arrFailed+=$item
        $intCount+=1
    }
}

Write-Host "Restarted $($intCount - $intFailed) of $intCount AppleTV's"

Write-Host ''
Write-Host $date