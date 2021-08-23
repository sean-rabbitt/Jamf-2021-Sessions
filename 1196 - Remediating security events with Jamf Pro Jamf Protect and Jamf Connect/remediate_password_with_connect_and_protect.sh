#!/bin/bash

#requires depnotify 1.1.7 or higher

DEPNOTIFY_PATH="/Applications/Utilities/DEPNotify.app"
CHANGEPASSWORDURL="https://www.jamf.com"

# Get current logged in user's shortname
loggedinUser=$(/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }')	
echo "Logged in user is $loggedinUser"

# Path to the preference with our current user's shortname
jamfConnectStateLocation="/Users/$loggedinUser/Library/Preferences/com.jamf.connect.state.plist"
echo "jamfConnectStateLocation"

# Read the preference key from the .plist with PlistBuddy.  If no preference, LastSignIn will be "No record found"
lastSignIn=$(/usr/libexec/PlistBuddy -c "Print :LastSignIn" "$jamfConnectStateLocation" || echo "No record found")

#Set up our while loop in case a user gets cute on us.
currentSignIn=$lastSignIn	

rm /var/tmp/depnotify.log
rm /var/tmp/com.depnotify.webview.done
rm /var/tmp/com.depnotify.registration.done

sudo -u $loggedinUser open -a "$DEPNOTIFY_PATH" --args -fullScreen

echo "Command: DeterminateOff:"  >> /var/tmp/depnotify.log
echo "Command: Image: /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertStopIcon.icns" >> /var/tmp/depnotify.log
echo "Command: MainTitle: Jamf Protect and \nJamf Connect Password Remediation" >> /var/tmp/depnotify.log
echo "Command: MainText: You must change your organizational password.  Change your password, and you will be prompted to update your local passowrd on this Mac.\n\nIf you have any questions, contact the Security telephone number on the back of your employee badge." >> /var/tmp/depnotify.log
echo "Status: " >> /var/tmp/depnotify.log
sleep 2
echo "Command: SetWebViewURL: $CHANGEPASSWORDURL" >> /var/tmp/depnotify.log
echo "Command: ContinueButtonWeb: Launch Password Change" >> /var/tmp/depnotify.log

while [ ! -f "/var/tmp/com.depnotify.webview.done" ]; do
	echo "$(date "+%a %h %d %H:%M:%S"): Waiting for user to finish web."
sleep 1
done

echo "Command: Image: /Applications/Jamf Connect.app/Contents/Resources/AppIcon.icns" >> /var/tmp/depnotify.log
echo "Command: MainTitle: Local Password Update" >> /var/tmp/depnotify.log
echo "Command: MainText: Jamf Connect will now launch.  You will be prompted to update your local password.\n\nIf you have any questions, contact the Security telephone number on the back of your employee badge." >> /var/tmp/depnotify.log
echo "Status: " >> /var/tmp/depnotify.log
echo "Command: ContinueButton: Change Local Password" >> /var/tmp/depnotify.log

open jamfconnect://signin
	
currentSignIn=$(/usr/libexec/PlistBuddy -c "Print :LastSignIn" "$jamfConnectStateLocation" || echo "No record found")
while [[ $currentSignIn == $lastSignIn ]]; do
	echo "Sleeping for 30"
	sleep 30
	open jamfconnect://networkcheck
	currentSignIn=$(/usr/libexec/PlistBuddy -c "Print :LastSignIn" "$jamfConnectStateLocation" || echo "No record found")
	echo "$currentSignIn and last was $lastSignIn"
	# if you want to do something to trigger the script again after x number of attempts here
	# go for it
done
	
	
#Clean up after ourselves
rm /var/tmp/com.depnotify.webview.done
rm /var/tmp/com.depnotify.registration.done	
		
#and here is where you put the code to erase the Jamf Protect directory to drop the device out of the
#smart computer group