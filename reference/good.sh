#!/bin/bash
# this_file: set_default_browser.sh

osascript -e '
tell application "System Events"
    -- Change default browser
    do shell script "defaultbrowser chrome"
    
    -- Wait for dialog and click
    delay 0.5
    try
        -- Get all buttons in the CoreServicesUIAgent window
        set buttonList to buttons of window 1 of process "CoreServicesUIAgent"
        
        -- Look for a button that contains "Chrome" (case-invariant)
        repeat with currentButton in buttonList
            set buttonTitle to name of currentButton as string
            ignoring case
                if buttonTitle contains "Chrome" then
                    click currentButton
                    exit repeat
                end if
            end ignoring
        end repeat
    end try
end tell
'
