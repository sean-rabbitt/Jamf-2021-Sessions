
#!/bin/bash
# Jamf Helper Script for Jamf Protect (High Threat Level)

jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"

#Header for Pop Up
heading="IT Security Notification"
#Description for Pop Up
description="Your computer may be infected with malware. Your network connection has been disabled. Please power down your Mac and call your IT administrator immediately at 888-867-5309"
#Button Text
button1="Ok"
#Path for Icon Displayed
icon="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertStopIcon.icns"

userChoice=$("$jamfHelper" -windowType utility -heading "$heading" -description "$description" -button1 "$button1" -icon "$icon")
        
        if [[ $userChoice == 0 ]]; then
                echo "user clicked $button1"
                exit 0 
fi