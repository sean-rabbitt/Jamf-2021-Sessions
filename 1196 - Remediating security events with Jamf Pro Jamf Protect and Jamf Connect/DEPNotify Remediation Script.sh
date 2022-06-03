#!/bin/bash
# Version 1.0.0
##########################################################################################################
# Script by Sean Rabbitt, Jamf Senior Sales Engineer and Kelli Conlin, Jamf Security Solutions Specialist 
##########################################################################################################

JAMF_PATH=$(which jamf)
echo "Jamf Path is $JAMF_PATH"

LOGGED_IN_USER=$( /usr/sbin/scutil <<< "show State:/Users/ConsoleUser" | /usr/bin/awk -F': ' '/[[:space:]]+Name[[:space:]]:/ { if ( $2 != "loginwindow" ) { print $2 }}' )
	
echo "Logged in user is $LOGGED_IN_USER"

LOGGED_IN_UID=$(/usr/bin/id -u "$LOGGED_IN_USER")
echo "Logged in user UID is $LOGGED_IN_UID"

# Remove DEP Notify log if present 
if [[ -f /var/tmp/depnotify.log ]]; then
	echo "Existing DEPNotify file found, deleting"
	rm /var/tmp/depnotify.log
fi

# DEP Notify for Jamf Protect
if [[ -f "/Applications/Utilities/DEPNotify.app/Contents/MacOS/DEPNotify" ]]; then
	echo "DEPNotify Found - starting"
	launchctl asuser $LOGGED_IN_UID open -a "/Applications/Utilities/DEPNotify.app" --args -fullScreen
else
	echo "DEP Notify Not Present.. downloading and installing"
	curl "https://files.nomad.menu/DEPNotify.pkg" -o /private/tmp/DEPNotify.pkg
	/usr/sbin/installer -pkg /private/tmp/DEPNotify.pkg -target /
	echo "DEPNotify Found - starting"
	launchctl asuser $LOGGED_IN_UID open -a "/Applications/Utilities/DEPNotify.app" --args -fullScreen
fi

# Update DEPNotify Icon
echo "Command: Image: /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertStopIcon.icns" >> /var/tmp/depnotify.log
 
# Update DEPNotify Title
echo "Command: MainTitle: Jamf Protect Remediation" >> /var/tmp/depnotify.log
 
# Update DEPNotify Main Body Text
echo "Command: MainText: Jamf Protect has detected malicious activity on this computer.\n\nYou may resume using your Mac once the malicious incident has been isolated.\n\n If this screen remains for longer than five minutes, please call the IT Department using the number on the back of your ID badge." >> /var/tmp/depnotify.log
 
# Update the DEPNotify progress bar
echo "Command: DeterminateManual: 5" >> /var/tmp/depnotify.log
echo "Command: DeterminateManualStep: 1" >> /var/tmp/depnotify.log

# Update DEPNotify Status Message
echo "Status: Remediation in progress..." >> /var/tmp/depnotify.log
sleep 3
 
# Update DEPNotify Status Message
echo "Status: Compressing forensic artifacts..." >> /var/tmp/depnotify.log
echo "Command: DeterminateManualStep: 1" >> /var/tmp/depnotify.log
sleep 3

# Capture the date & time
dateStamp=$(date +%Y_%m_%d-%H_%M_%S)

# Check for and remove a LaunchDaemon if found
if [[  -f /Library/LaunchDaemons/com.celastradepro.plist ]];then
	launchctl bootout system /Library/LaunchDaemons/com.celastradepro.plist
	rm -rf /Library/LaunchDaemons/com.celastradepro.plist
fi
 
# Zip the Malware
cd /Library/Application\ Support/JamfProtect/Quarantine/*; zip -r -X "../Malware-$dateStamp.zip" *

# Update DEPNotify Status Message
echo "Status: Moving forensic artifacts..." >> /var/tmp/depnotify.log
echo "Command: DeterminateManualStep: 1" >> /var/tmp/depnotify.log
sleep 3

# Move Malware to a new location, Default is /Users/Shared
cd /Library/Application\ Support/JamfProtect/Quarantine/; mv "Malware-$dateStamp.zip" /Users/Shared/
 
# Remove the Quarantined Malware
rm -R /Library/Application\ Support/JamfProtect/Quarantine/*

# Clear DEPNotify Status Message
echo "Command: DeterminateManualStep: 1" >> /var/tmp/depnotify.log
echo "Status: " >> /var/tmp/depnotify.log

# DEPNotify app Completed Title 
echo "Command: MainTitle: Remediation Complete" >> /var/tmp/depnotify.log

# DEPNotify app Completed Icon 
echo "Command: Image: /Applications/JamfProtect.app/Contents/Resources/AppIcon.icns" >> /var/tmp/depnotify.log 

# DEPNotify app Completed Text Body
echo "Command: MainText: The malicious element was isolated. Thank you for your patience.\n\nAs a reminder, your security is of the utmost importance. If you receive any unusual emails or phone calls asking for your username, password, or any other requests, please call the IT Department using the number on the back of your ID badge." >> /var/tmp/depnotify.log
 sleep 4
 
# Quit the DEPNotify app
echo "Command: Quit" >> /var/tmp/depnotify.log

# Remove the DEPNotify log file
rm /var/tmp/depnotify.log

# Remove Forensic Artifact from the computer
rm -rf /Users/Shared/Malware*.zip

# Remove Jamf Protect Extension Attribute 
rm /Library/Application\ Support/JamfProtect/groups/*
# Quit DEPNotify app if the quit command failed
pkill DEPNotify

# Remove DEPNotify.app
# rm -R /Applications/Utilities/DEPNotify.app
 
exit 0


