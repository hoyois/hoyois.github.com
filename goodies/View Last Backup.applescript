(* View Last Backup 2014-10-30 *)

(* Wrapper for the timedog Perl script: http://code.google.com/p/timedog/ *)

on run
	-- User-specific variables
	set timeMachineVolume to "Time Machine"
	set computerName to "Marc’s MacBook Pro"
	
	if (fileExists("/Volumes/" & timeMachineVolume & "/Backups.backupdb/" & computerName)) then
		
		-- Options
		set optionsDialog to display dialog "Directory depth:" with icon alias ":Applications:Time Machine.app:Contents:Resources:backup.icns" default answer "5" with title "View Last Time Machine Backup" buttons {"Cancel", "Sort alphabetically", "Sort by size"} default button 3
		set depth to the text returned of optionsDialog
		set sortMethod to the button returned of optionsDialog
		if (sortMethod is "Cancel") then return
		set sortBySize to "undef"
		if sortMethod is "Sort by size" then set sortBySize to "1"
		
		-- Run timedog
		set backupedFiles to do shell script "cd /Volumes/" & escapeSpaces(timeMachineVolume) & "/Backups.backupdb/" & escapeSpaces(computerName) & ";" & "/usr/bin/perl -e \"use File::Find;use Fcntl ':mode';use Getopt::Std;\\$opt_s=" & sortBySize & ";\\$opt_d=" & depth & ";sub bytes{my \\$bytes=shift;\\$format=shift||\\\".1\\\";@suff=(\\\"B\\\",\\\"KB\\\",\\\"MB\\\",\\\"GB\\\",\\\"TB\\\");for(\\$suff=shift @suff;\\$#suff>=0 and \\$bytes>=1000.;\\$suff=shift @suff){\\$bytes/=1024.;}return int(\\$bytes).\\$suff if int(\\$bytes)==\\$bytes;return sprintf(\\\"%\\${format}f\\\",\\$bytes).\\$suff;}sub summarize{(\\$size,\\$size_old,\\$old_exists,\\$name,\\$cnt)=@_;push @summary,[\\$size,sprintf(\\\"%9s->%9s %6s %s\\n\\\",\\$old_exists?bytes(\\$size_old):\\\".... \\\",bytes(\\$size),\\$cnt?\\\"[\\$cnt]\\\":\\\"\\\",\\$name)];}opendir DIR,\\\".\\\" or die \\\"Can't open directory.\\\";@files=sort grep{m|[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]+\\$|}readdir(DIR);die \\\"None or only one Time Machine backups found.\\\" if @files==1;(\\$last,\\$latest)=@files[\\$#files-1..\\$#files];print \\\"==> Comparing TM backup \\$latest to \\$last\\n\\\";my (\\$old_exists,\\$rold_exists,\\$rsize,\\$rsize_old);\\$total_size=0;\\$total_cnt=0;%conv=('k'=>1024,'m'=>1024**2,'g'=>1024**3,'t'=>1024**4);print \\\"    Depth: \\$opt_d directories  \\\";print \\\"\\n\\\";find({wanted=>sub{(\\$dev,\\$ino,\\$mode,\\$nlink,\\$uid,\\$gid,\\$rdev,\\$size)=lstat(\\$_);(\\$old=\\$_)=~s/^\\$latest/\\$last/;if(-e \\$old){(\\$dev,\\$ino_old,\\$mode_old,\\$nlink,\\$uid,\\$gid,\\$rdev,\\$size_old)=lstat(\\$old);if(\\$ino==\\$ino_old){\\$File::Find::prune=1 if -d;return}\\$old_exists=1;}else{\\$old_exists=0;}\\$total_size+=\\$size;\\$link=S_ISLNK(\\$mode);return if \\$link;\\$total_cnt++;(\\$name=\\$_)=~s/^\\$latest//;\\$depth=\\$name=~tr|/||;\\$rsize+=\\$size;\\$rsize_old+=\\$size_old if \\$old_exists;\\$rcnt++;return if S_ISDIR(\\$mode)||\\$depth>\\$opt_d;\\$name.=\\\"/\\\" if S_ISDIR(\\$mode);\\$name.=\\\"@\\\" if \\$link;summarize(\\$size,\\$size_old,\\$old_exists,\\$name);},preprocess=>sub{\\$depth=\\$File::Find::dir=~tr|/||;if(\\$depth<=\\$opt_d){\\$rsize=\\$rsize_old=\\$rcnt=0;\\$rold_exists=-e \\$File::Find::dir;}@_;},postprocess=>sub{\\$depth=\\$File::Find::dir=~tr|/||;return if \\$depth>\\$opt_d;(\\$name=\\$File::Find::dir)=~s/^\\$latest//;summarize(\\$rsize,\\$rsize_old,\\$rold_exists,\\$name.'/',\\$rcnt) if \\$rsize||\\$rsize_old;\\$rsize=\\$rsize_old=\\$rcnt=0;},no_chdir=>1},\\$latest);if(\\$opt_s){foreach(map{\\$_->[1]}sort{\\$b->[0]<=>\\$a->[0]}@summary){print;}}else{foreach(map{\\$_->[1]}@summary){print;}}print \\\"==> Total Backup: \\$total_cnt changed files/directories, \\\",bytes(\\$total_size,\\\".2\\\"),\\\"\\n\\\";\""
		
		-- Show result in TextEdit
		tell application "TextEdit"
			set d to make new document
			repeat with w in windows
				if document of w is d then
					set bounds of w to {133, 49, 1000, 600}
					exit repeat
				end if
			end repeat
			tell d
				set paragraph 1 to "​" -- zero-width space, to set font
				set font to "Menlo"
				set size to 11
				set paragraph 2 to backupedFiles
			end tell
			activate
		end tell
	else
		display dialog "You must connect the “" & timeMachineVolume & "” volume to view the last backup." with icon alias ":Applications:Time Machine.app:Contents:Resources:backup.icns" with title "View Last Time Machine Backup" buttons {"OK"} default button 1
	end if
end run

on fileExists(filePath)
	try
		POSIX file filePath as alias
		return true
	on error
		return false
	end try
end fileExists

on escapeSpaces(s)
	set oldDelimiters to AppleScript's text item delimiters
	set AppleScript's text item delimiters to " "
	set t to text items of s
	set AppleScript's text item delimiters to "\\ "
	set s to t as Unicode text
	set AppleScript's text item delimiters to oldDelimiters
	return s
end escapeSpaces
