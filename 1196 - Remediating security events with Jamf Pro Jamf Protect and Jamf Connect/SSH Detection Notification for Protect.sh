#!/bin/bash
#Check for SSH Activity 
sshcheck=$(lsof -i | grep ssh)
echo "$sshcheck"
if [ -z "$sshcheck" ] ; then
	echo "No Active SSH Activity"
else 
	jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
	#Header for Pop Up
	heading="IT Security Notification"
	#Description for Pop Up
	description="There is unusal activity happening on your device. Have you authorized SSH communication recently?"
	#Button Text
	button1="Yes"
	button2="No"
	#Path for Icon Displayed
	icon="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertStopIcon.icns"
	userChoice=$("$jamfHelper" -windowType utility -heading "$heading" -description "$description" -button1 "$button1" -button2 "$button2" -icon "$icon")
		if [[ $userChoice == 0 ]]; then
			echo "<result>No Suspicious SSH</result>"
		else
			echo "<result>Unwanted SSH</result>"		
		fi	
fi