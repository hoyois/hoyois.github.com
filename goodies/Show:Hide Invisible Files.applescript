(* Show/Hide Invisible Files 2012-07-28 *)

on run
	tell application "Finder"
		set hadWindows to (count windows) > 0
	end tell
	
	-- Toggle AppleShowAllFiles
	(* Note: it's very important that the dialogs below be NOT displayed by the Finder. Putting the Finder in the background makes it write its window state to the plist. *)
	try
		set status to do shell script "/usr/bin/defaults read com.apple.Finder AppleShowAllFiles"
	on error
		set status to "0"
	end try
	if status = "1" then
		set d to display dialog "To hide all invisible files, the Finder must be relauched." with icon alias ":System:Library:CoreServices:Finder.app:Contents:Resources:Finder.icns" with title "Hide Invisible Files" buttons {"Cancel", "Relauch Finder"} default button "Relauch Finder"
		if button returned of d = "Relauch Finder" then
			do shell script "/usr/bin/defaults write com.apple.Finder AppleShowAllFiles 0"
		else
			return 0
		end if
	else
		set d to display dialog "To show all invisible files, the Finder must be relauched." with icon alias ":System:Library:CoreServices:Finder.app:Contents:Resources:Finder.icns" with title "Show All Files" buttons {"Cancel", "Relauch Finder"} default button "Relauch Finder"
		if button returned of d = "Relauch Finder" then
			do shell script "/usr/bin/defaults write com.apple.Finder AppleShowAllFiles 1"
		else
			return 0
		end if
	end if
	
	-- Use launchd to relaunch Finder instantaneously
	do shell script "launchctl stop com.apple.Finder && launchctl start com.apple.Finder"
	(* Notes: This is even faster than kill && open. Windows are restored on launch regardless of the 'Restore windows' setting in Lion *)
	
	-- Wait for Finder
	tell application "System Events"
		repeat while (name of processes) does not contain "Finder"
			tell me to do shell script "sleep .1"
		end repeat
	end tell
	
	-- Switch to Finder
	tell application "Finder"
		if hadWindows then
			-- Wait for a window to be opened, otherwise they will open in the background
			repeat 10 times
				if (count windows) > 0 then exit repeat
				tell me to do shell script "sleep .1"
			end repeat
		end if
		activate
	end tell
end run
