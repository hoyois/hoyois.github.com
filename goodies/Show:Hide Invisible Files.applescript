on run
	(* Switch to another app to force Finder to write its current window state to its plist file *)
	tell application "System Events" to activate
	tell application "Finder" to activate
	
	if (do shell script "/usr/bin/defaults read com.apple.Finder AppleShowAllFiles") = "1" then
		tell application "Finder" to set showPrompt to display alert "Are you sure you want to hide all invisible files?" message "The Finder will quit and relaunch afterwards." buttons {"Cancel", "Hide Invisible Files"} default button "Hide Invisible Files"
		if button returned of showPrompt = "Hide Invisible Files" then
			do shell script "/usr/bin/defaults write com.apple.Finder AppleShowAllFiles 0"
		else
			return 0
		end if
	else
		tell application "Finder" to set showPrompt to display alert "Are you sure you want to show all invisible files?" message "The Finder will quit and relaunch afterwards." buttons {"Cancel", "Show Invisible Files"} default button "Show Invisible Files"
		if button returned of showPrompt = "Show Invisible Files" then
			do shell script "/usr/bin/defaults write com.apple.Finder AppleShowAllFiles 1"
		else
			return 0
		end if
	end if
	relaunchFinder()
end run

on relaunchFinder()
	(* Use launchctl to relaunch Finder instantaneously *)
	do shell script "launchctl stop com.apple.Finder && launchctl start com.apple.Finder"
	(* Must wait until Finder reopens all its windows, because each new window puts Finder in the background *)
	do shell script "sleep 1"
	tell application "Finder" to set frontmost to true
end relaunchFinder