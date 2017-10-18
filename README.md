# check_backups

the script has about 50 tests that run to check for stuff like :

ownership and permissions of folders, files symlink<br />
it check acl, block and character devices, extended attributes<br />
modification, accesstime of files<br />
some weird thing like set modification time in year 1000 and 3000<br />
some unicode charaters in filenames<br />
very long filenames, folders with a lot of files and folders inside<br /><br />
setting ownership to users that do not exists on that system<br />
bugged symlink, looped symlink, hardlink count<br />
sparse files<br />

if you have more ideas of things to check, please submit.


the backup/restore commands for urbackup are pre-configured
if needed edit the commands to use to backup and restore files at the begining of the script

#run this to create the test files<br />
check_backups.sh WRITE

#run this to check for original report, all checks should be OK <br />
check_backups.sh READ

#optional, list the created file<br />
check_backups.sh LIST

#make a backup/<br />
check_backups.sh BACKUP

#delete the test files in /tmp/filetests/<br />
check_backups.sh DELETE

#restore files <br />
check_backups.sh RESTORE

#optional, list restored files <br />
check_backups.sh LIST

#run this to check for differences with the first report <br />
check_backups.sh READ

#show only errors <br />
check_backups.sh READ | grep -B2 KO
