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



#Output looks like :
check_backups.sh READ
#===== setting up env =================================
=========WRITE MODE
created /tmp/filetests/

#=====test_users =================================
test 1 :file,  user doesn t exist locally
OK same grp id : 50123
OK same grp id : 50123
test 2 : folder user don t exist locally
OK same user id : 50123
OK same grp id : 50123
test 3 file,  10th  user, 11th group
OK same user id news
OK same grp id : uucp
test 4 file,  last passwd user id
OK same user id nova
OK same grp id : nova
test 5 folder, random user
OK same user id news
OK same grp id : uucp
test 6 folder, last passwd user id
OK same user id nova
OK same grp id : nova

#===== test_permissions	===================================
test 7  file permissions 444
OK permissions is good : -r--r--r--
test 8  folder permissions 444
OK permissions is good : dr--r--r--
test 9 file  permissions 2666
OK permissions is good : -rw-rwSrw-
test 10 folder  permissions 2666
OK permissions is good : drw-rwSrw-
test 11 file  permissions u+s
OK permissions is good : -rwSr--r--
test 12 file  permissions ug+s
OK permissions is good : -rwSr-Sr--

#===== test_acl	===================================
test 13 file  acl
OK same user id : proxy 
OK same grp id : proxy 
test 14 folder acl
OK same user id : proxy 
OK same grp id : proxy 

#====== test_dates ===============================
test 15 file mtime
OK mtime is good : 1325372400
test 16 file mtime in the futur
OK mtime is good : 10325314800
test 17 file mtime is negative
OK mtime is good : -21231590961
test 18 folder mtime
OK mtime is good : 1325372400
test 19 file atime
OK mtime is good : 1325372400 
test 20 folder atime
OK mtime is good : 1325372400 

#====== test_links	=============================
test 21 symlink permissions
OK same user id news
OK same grp id : uucp
test 22 file hardlink
OK 3 hard link
test 23 file symlink
OK sym link
test 24 folder symlink
OK sym link
test 25 invalid looped symlink
OK symlink exists 
test 26 folder symlink loop
OK symlink exists 

#====== test_specialdevices	==============================
test 27 character device
OK type is good : c
OK major : 3
OK minor : 2
test 28 character device
OK type is good : c
OK major : 3
OK minor : 3
test 29 character device
OK type is good : b
OK major : 1
OK minor : 0
test 30 fifo
OK , fifo ,p

#===== test_xattrs	===========================
test 31 file  xattrs
OK same xattrs : this is a test
test 32 folder xattrs
OK same xattrs : this is a test

#===== test_bincopy	===========================
test 33 md5sum of ls -lk /bin copy
OK same md5 399d70d2aad1e0cd817f9b34bdf6d7e1 *-
test 34 md5sum of ls -lk /bin copy , exclude hardlink count
OK same md5 8194aa7721cd48baccbf5cf9430a16a9 *-

#======= test_highvalues	==============================
test 35 254 char filename
OK long filename exists
test 36 254 folder name
OK long folder exists
test 37  254 char filename in 254 folder name
OK long filename exists
test 38 2048 files in folder
OK all files present
test 39 2048 folders in folder
OK all folders
test 40 100 subfolders levels
OK all folders

#======= test_onefileperuser	==========================
test 41 1 file per user in passwd
OK  good ownership
test 42 1 file per user in passwd in one folder per user
OK  good ownership

#====== test_sparsefile	=============================
test 43 totally sparse file
OK file is sparse 0 10240
test 44 partially sparse file 
OK file is partially sparse 1908 2683


