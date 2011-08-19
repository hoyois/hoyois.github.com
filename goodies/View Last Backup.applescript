(*
Simple timedog wrapper
Displays latest backuped files in a TextEdit window.
*)
on run
	-- User-specific variables
	set time_machine_volume to "Time Machine"
	set computer_name to "Marc HoyoisÕs MacBook Pro"
	
	if (f_exists("/Volumes/" & time_machine_volume & "/Backups.backupdb/" & computer_name)) then
		tell application "System Events"
			set wasTextEditRunning to (name of processes) contains "TextEdit"
		end tell
		
		set get_depth to display dialog "Directory depth:" default answer "5" with title "View Last Time Machine Backup" buttons {"Cancel", "Sort alphabetically", "Sort by size"} default button 3
		set depth to the text returned of get_depth
		set sort_method to the button returned of get_depth
		
		if (sort_method is "Cancel") then return
		set sort_by_size to "undef"
		if sort_method is "Sort by size" then set sort_by_size to "1"
		set backuped_files to do shell script "cd /Volumes/" & escape_spaces(time_machine_volume) & "/Backups.backupdb/" & escape_spaces(computer_name) & "; " & "/usr/bin/perl -e \"use File::Find;use Fcntl ':mode';use Getopt::Std;\\$opt_l = undef;\\$opt_n = undef;\\$opt_m = undef;\\$opt_d = " & depth & ";\\$opt_s = " & sort_by_size & ";sub bytes {my \\$bytes=shift;\\$format=shift || \\\".1\\\";@suff=(\\\"B\\\",\\\"KB\\\",\\\"MB\\\",\\\"GB\\\",\\\"TB\\\");for (\\$suff=shift @suff; \\$#suff>=0 and \\$bytes>=1000.; \\$suff=shift @suff) {\\$bytes/=1024.;}return int(\\$bytes) . \\$suff if int(\\$bytes)==\\$bytes;return sprintf(\\\"%\\${format}f\\\",\\$bytes) . \\$suff;}sub summarize {(\\$size,\\$size_old,\\$old_exists,\\$name,\\$cnt)=@_;return if \\$opt_m && \\$size<\\$opt_m;if (\\$opt_n){push @summary,[\\$size,sprintf(\\\"%12d %12d %s
\\\",\\$old_exists?\\$size_old:0,\\$size,\\$name)];}else{if (\\$opt_d) {push @summary,[\\$size,sprintf(\\\"%9s->%9s %6s %s
\\\",\\$old_exists?bytes(\\$size_old):\\\".... \\\",bytes(\\$size),\\$cnt?\\\"[\\$cnt]\\\":\\\"\\\",\\$name)];} else {push @summary,[\\$size,sprintf(\\\"%9s->%9s %s
\\\",\\$old_exists?bytes(\\$size_old):\\\".... \\\",bytes(\\$size),\\$name)];}}}opendir DIR,\\\".\\\" or die \\\"Can't open directory.\\\";@files=sort grep {m|[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]+\\$|} readdir(DIR);die \\\"None or only one Time Machine backups found.\\\" if @files == 1;(\\$last,\\$latest)=@files[\\$#files-1..\\$#files];print \\\"==> Comparing TM backup \\$latest to \\$last
\\\" unless \\$opt_n;my (\\$old_exists,\\$rold_exists,\\$rsize,\\$rsize_old);\\$total_size=0;\\$total_cnt=0;%conv=('k' => 1024, 'm' => 1024**2, 'g'=>1024**3,'t'=>1024**4);if (\\$opt_m){\\$opt_m=~/([0-9.]+)([kmgt]?)/i;\\$opt_m=\\$1;\\$opt_m*=\\$conv{lc \\$2} if \\$2;}unless (\\$opt_n) {if (\\$opt_d) {print \\\"    Depth: \\$opt_d directories  \\\"}if (\\$opt_m) {print \\\"Omitting if smaller than: \\\",bytes(\\$opt_m),\\\"
\\\";} else { print \\\"
\\\" if \\$opt_d;}}find({wanted =>sub{(\\$dev,\\$ino,\\$mode,\\$nlink,\\$uid,\\$gid,\\$rdev,\\$size) = lstat(\\$_);(\\$old=\\$_)=~s/^\\$latest/\\$last/;if (-e \\$old) {(\\$dev, \\$ino_old,\\$mode_old,\\$nlink,\\$uid,\\$gid,\\$rdev,\\$size_old) = lstat(\\$old);if (\\$ino == \\$ino_old) {\\$File::Find::prune=1 if -d;return  }\\$old_exists=1;} else {\\$old_exists=0;}\\$total_size+=\\$size;\\$link=S_ISLNK(\\$mode);return if \\$opt_l && \\$link;\\$total_cnt++;(\\$name=\\$_)=~s/^\\$latest//;if (\\$opt_d) {\\$depth=\\$name=~tr|/||;\\$rsize+=\\$size;  \\$rsize_old+=\\$size_old if \\$old_exists;\\$rcnt++;  return if S_ISDIR(\\$mode) || \\$depth > \\$opt_d;}\\$name.=\\\"/\\\" if S_ISDIR(\\$mode);\\$name.=\\\"@\\\" if \\$link;summarize(\\$size,\\$size_old,\\$old_exists,\\$name);},preprocess =>(\\!\\$opt_d)?0:sub{\\$depth=\\$File::Find::dir=~tr|/||;if (\\$depth<=\\$opt_d) {\\$rsize=\\$rsize_old=\\$rcnt=0;  \\$rold_exists=-e \\$File::Find::dir;}@_;}, postprocess =>(\\!\\$opt_d)?0:sub{\\$depth=\\$File::Find::dir=~tr|/||;return if \\$depth > \\$opt_d;(\\$name=\\$File::Find::dir)=~s/^\\$latest//;summarize(\\$rsize,\\$rsize_old,\\$rold_exists,\\$name.'/',\\$rcnt)  if \\$rsize || \\$rsize_old;\\$rsize=\\$rsize_old=\\$rcnt=0;},no_chdir => 1}, \\$latest);if (\\$opt_s) {foreach (map {\\$_->[1]} sort {\\$b->[0] <=> \\$a->[0]} @summary) { print;}} else {foreach (map {\\$_->[1]} @summary) { print;}}print \\\"==> Total Backup: \\$total_cnt changed files/directories, \\\",  bytes(\\$total_size,\\\".2\\\"),\\\"
\\\" unless \\$opt_n;\""
		
		tell application "TextEdit"
			if wasTextEditRunning then
				make new document at the end of documents of it
			end if
			set bounds of window 1 to {133, 49, 1000, 600}
			tell the front document
				set paragraph 1 to backuped_files
				set font to "Monaco"
				set size to 10
			end tell
			activate
		end tell
	else
		display dialog "Please connect the Ò" & time_machine_volume & "Ó volume to view the last backup." with title "View Last Backup" buttons {"OK"} default button 1
		
	end if
	
end run

on f_exists(the_path)
	try
		POSIX file the_path as alias
		return true
	on error
		return false
	end try
end f_exists

on escape_spaces(s)
	set old_delimiters to AppleScript's text item delimiters
	set AppleScript's text item delimiters to " "
	set exp_string to text items of s
	set AppleScript's text item delimiters to "\\ "
	set s to exp_string as Unicode text
	set AppleScript's text item delimiters to old_delimiters
	return s
end escape_spaces
