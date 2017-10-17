# check_backups

#run this to create test files
check_backups.sh WRITE

#make a backup

#list created file
check_backups.sh LIST

#delete the test files in /tmp/filetests/
check_backups.sh DELETE

#restore files (build in command for urbackup)
check_backups.sh RESTORE

#list restored file
check_backups.sh LIST

#run this to check for differences
check_backups.sh READ

#show only errors
check_backups.sh READ | grep -B2 KO
