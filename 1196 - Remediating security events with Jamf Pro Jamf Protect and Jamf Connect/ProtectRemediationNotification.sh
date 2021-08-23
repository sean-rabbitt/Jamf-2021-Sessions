#!/bin/bash

# DEP Notify for Jamf Protect

if [ -f "/Applications/Utilities/DEPNotify.app/Contents/MacOS/DEPNotify" ]; then
	/Applications/Utilities/DEPNotify.app/Contents/MacOS/DEPNotify -fullScreen &
else
	exit 1;
fi

echo "Command: Image: /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertStopIcon.icns" >> /var/tmp/depnotify.log
echo "Command: MainTitle: Jamf Protect Remediation" >> /var/tmp/depnotify.log
echo "Command: MainText: Malicious activity on this computer has been detected by Jamf Protect.\nIf this screen appears for longer than 30 seconds, call the IT Department on the back of your badge to create a help desk ticket.\n \nControl will return when the malicious software has been isolated." >> /var/tmp/depnotify.log
echo "Status: Isolating malicious software..." >> /var/tmp/depnotify.log
echo "Command: Determinate: 2" >> /var/tmp/depnotify.log

# Here's where you would put your Jamf policy command
# /usr/local/bin/jamf policy -event kelliRocks
sleep 2

echo "Status: The malicious software has been isolated." >> /var/tmp/depnotify.log
echo "Command: DeterminateManualStep" >> /var/tmp/depnotify.log
sleep 2 # Optional sleeps...

echo "Command: MainTitle: Remediation Complete" >> /var/tmp/depnotify.log
echo "Command: Image: /Library/Application Support/JamfProtect/JamfProtect.app/Contents/Resources/AppIcon.icns" >> /var/tmp/depnotify.log
echo "Command: MainText: The malicious software has been isolated. Reboot is recommended.\n \nSave your work and reboot your computer.\n\nPhishing attempts are the biggest risk to organization data.  If you receive any unusual emails or phone calls asking for access to your user name, password, requests to install software, or start screen sharing to your computer, contact the IT Security Department by calling the number on the back of your badge. \nHave your Employee ID ready when you call." >> /var/tmp/depnotify.log
echo "Command: DeterminateManualStep" >> /var/tmp/depnotify.log
echo "Status: " >> /var/tmp/depnotify.log
echo "Command: ContinueButton: Continue" >> /var/tmp/depnotify.log

# Alternative Command to force a restart:
#echo "Command: ContinueButtonRestart: Restart" >> /var/tmp/depnotify.log

rm /var/tmp/depnotify.log 
rm /var/tmp/com.depnotify.provisioning.done
# If forcing a restart
#rm /var/tmp/com.depnotify.provisioning.restart