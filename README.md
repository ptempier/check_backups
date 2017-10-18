# check_backups

#run this to create test files<br />
check_backups.sh WRITE

#make a backup
check_backups.sh BACKUP

#list created file<br />
check_backups.sh LIST

#delete the test files in /tmp/filetests/<br />
check_backups.sh DELETE

#restore files <br />
check_backups.sh RESTORE

#list restored file <br />
check_backups.sh LIST

#run this to check for differences <br />
check_backups.sh READ

#show only errors <br />
check_backups.sh READ | grep -B2 KO
