(* Show/Hide Invisible Files 2012-07-28 *)

-- Get status
try
	set status to do shell script "defaults read com.apple.finder AppleShowAllFiles"
on error
	set status to "0"
end try

-- Toggle AppleShowAllFiles
if status = "0" then
	set d to display dialog "To show all files, the Finder must be relauched." with icon alias ":System:Library:CoreServices:Finder.app:Contents:Resources:Finder.icns" with title "Show All Files" buttons {"Cancel", "Relauch Finder"} default button "Relauch Finder"
	if button returned of d = "Relauch Finder" then
		do shell script "defaults write com.apple.finder AppleShowAllFiles -bool YES"
	else
		return 0
	end if
else
	set d to display dialog "To hide all invisible files, the Finder must be relauched." with icon alias ":System:Library:CoreServices:Finder.app:Contents:Resources:Finder.icns" with title "Hide Invisible Files" buttons {"Cancel", "Relauch Finder"} default button "Relauch Finder"
	if button returned of d = "Relauch Finder" then
		do shell script "defaults write com.apple.finder AppleShowAllFiles -bool NO"
	else
		return 0
	end if
end if

-- Use launchd to relauch the Finder instantly (notice the uppercase "F"!)
do shell script "launchctl stop com.apple.Finder && launchctl start com.apple.Finder"

-- Switch to Finder
tell application "Finder"
launch
activate
end tell
