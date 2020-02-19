# Written by Heiko Horn on 2020.02.14
# This script check all AppleTv objects in Jamf and send a managed command to restart them.
# To run this on a Mac you need to install PowerShell for macOS from https://github.com/PowerShell/PowerShell

## Please change this value to the current version.
# Current iOS version
$strVersion='13.3.1'

## Please don't modify these values
# Convert the version string into a version variable, so that we can compare it later
[version]$verCurrent=$strVersion
# Common Variables
$arrUpdate=@()
# macOS / Unix specific variables
$strPlist='./JAMF.plist'
# Windows specific variables
$strRegistry='Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Munich International School\JAMF'
# Enable SSL connection using TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Function to read a PLIST file with single entry using the key values
function ReadPlistKey ($xmlPlist) {   
    $xmlPlist.plist.dict | 
    ForEach-Object { 
        $_.SelectNodes('key') | 
        ForEach-Object {$ht=@{}} {$ht[$_.'#text'] = $_.NextSibling.'#text'} {New-Object PSObject -Property $ht}
    }
}

# Function to send restart managed command
function updateOS ($strID) {
    Invoke-RestMethod -Uri "$strUrl/mobiledevicecommands/command/ScheduleOSUpdate/2/id/$strID" -Headers @{Authorization=("Basic {0}" -f $strAuth); "Accept"="application/xml"} -Method Post
}

# Function to send update inventory managed command
function updateInventory ($id) {
    Invoke-RestMethod -Uri "$strUrl/mobiledevicecommands/command/UpdateInventory/id/$id" -Headers @{Authorization=("Basic {0}" -f $strAuth); "Accept"="application/xml"} -Method Post
}

# Function to get all mobile devices
function getAllDevices () {
    Invoke-RestMethod -Uri "$strUrl/mobiledevices" -Headers @{Authorization=("Basic {0}" -f $strAuth); "Accept"="application/xml"}
}

# Function to single mobile devices
function getMobileDevice ($id) {
    Invoke-RestMethod -Uri "$strUrl/mobiledevices/id/$id" -Headers @{Authorization=("Basic {0}" -f $strAuth); "Accept"="application/xml"}
}

# Check if Powershell is running on UNIX or Windows OS Platform
if ([environment]::OSVersion.Platform -eq 'Unix') {
    # Get the Base64 Authentication key by parsing a PLIST file
    $xmlPlist=([xml]$(Get-Content $strPlist))
    $hashPlist=ReadPlistKey $xmlPlist
    $strAuth=$hashPlist.apiToken
    $strUrl=$hashPlist.apiUrl
} else {
    # Get the Base64 Authentication key by reading the Windows Registry
    $hashRegistry=Get-ItemProperty -Path $strRegistry
    $strAuth=$hashRegistry.apiToken
    $strUrl=$hashRegistry.apiUrl
}

# Get all mobile device objects in Jamf Pro
$objJamf=getAllDevices
Write-Host "INFO - Getting mobile devices that are not on version: $($verCurrent.ToString())`n" -ForegroundColor Yellow
foreach ($item in $objJamf.mobile_devices.mobile_device) {
    if (($item.model_identifier -like 'AppleTV*') -and ($item.supervised -eq 'true')) {
        $id=$item.id
        # Check which version is currently on the AppleTV
        $objDevice=getMobileDevice $id
        [version]$verDevice=$objDevice.mobile_device.general.os_version
        if ($verDevice -lt $verCurrent) {
            Write-Host "Name: $($item.name) `nVersion: $strVersion`n"
            # Create an object for every device, so that we can retrieve the information later from an object array.
            $objUdateDevice=New-Object -TypeName PSObject
            Add-Member -InputObject $objUdateDevice -MemberType NoteProperty -Name Id -Value "$($item.id)"
            Add-Member -InputObject $objUdateDevice -MemberType NoteProperty -Name Name -Value "$($item.Name)"
            Add-Member -InputObject $objUdateDevice -MemberType NoteProperty -Name Version -Value "$($verDevice.ToString())"
            $arrUpdate+=$objUdateDevice
        }
    }
}

# Update iOS to the latest version and restart the device
Write-Host "INFO - Updating iOS on $($arrUpdate.count) devices to version: $($verCurrent.ToString())`n" -ForegroundColor Yellow
$strID=$arrUpdate.Id -join ","
$objUpdate=updateOS $strID
foreach ($objUpdateItem in $objUpdate.mobile_device_command.mobile_devices.mobile_device) {
    Write-Host "Name: $($($arrUpdate | Where-Object{$_.id -eq $objUpdateItem.Id}).Name) `nID: $($objUpdateItem.Id)`nVersion: $($($arrUpdate | Where-Object{$_.id -eq $objUpdateItem.Id}).Version)`nStatus: $($objUpdateItem.status)`n"
}

# Wait 10 Minutes before updating the Inventory
Write-Host "INFO - Wait 10 Minutes before updating the inventory`n" -ForegroundColor Yellow
Start-Sleep 600 

# Update Inventory
Write-Host "INFO - Updating inventory`n" -ForegroundColor Yellow
foreach ($objItem in $arrUpdate) {
    $objInventory=updateInventory $objItem.Id
    Write-Host "Name: $($objItem.Name) `nID: $($objItem.Id)`nVersion: $($objItem.Version)`nStatus: $($objInventory.mobile_device_command.mobile_devices.mobile_device.status)`n"
}

Write-Host ''
Write-Host $date