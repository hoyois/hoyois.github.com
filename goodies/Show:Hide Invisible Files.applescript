(* Show/Hide Invisible Files 2011-08-20 *)

on run
	-- Switch to another app to force Finder to write current window state to plist
	tell application "System Events" to activate
	tell application "Finder"
		activate
		set hadWindows to (count windows) > 0
	end tell
	
	-- Toggle AppleShowAllFiles
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
	
	-- Use launchd to relaunch Finder instantaneously
	do shell script "launchctl stop com.apple.Finder && launchctl start com.apple.Finder"
	(* Notes: This is even faster than kill && open. Windows are restored on launch regardless of the 'Restore windows' setting in Lion *)
	
	-- Wait for Finder to be scriptable
	tell application "System Events"
		repeat while (name of processes) does not contain "Finder"
			do shell script "sleep .1"
		end repeat
	end tell
	
	-- Switch to Finder
	tell application "Finder"
		if hadWindows then
			-- Wait for a window to be opened, otherwise they will open in the background
			repeat 10 times
				if (count windows) > 0 then exit repeat
				do shell script "sleep .1"
			end repeat
		end if
		activate
	end tell
end run