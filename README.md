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



#Output looks like :<br />
check_backups.sh READ<br />
#===== setting up env =================================<br />
=========WRITE MODE<br />
created /tmp/filetests/<br />
<br />
#=====test_users =================================<br />
test 1 :file,  user doesn t exist locally<br />
OK same grp id : 50123<br />
OK same grp id : 50123<br />
test 2 : folder user don t exist locally<br />
OK same user id : 50123<br />
OK same grp id : 50123<br />
test 3 file,  10th  user, 11th group<br />
OK same user id news<br />
OK same grp id : uucp<br />
test 4 file,  last passwd user id<br />
OK same user id nova<br />
OK same grp id : nova<br />
test 5 folder, random user<br />
OK same user id news<br />
OK same grp id : uucp<br />
test 6 folder, last passwd user id<br />
OK same user id nova<br />
OK same grp id : nova<br />
<br />
#===== test_permissions	===================================<br />
test 7  file permissions 444<br />
OK permissions is good : -r--r--r--<br />
test 8  folder permissions 444<br />
OK permissions is good : dr--r--r--<br />
test 9 file  permissions 2666<br />
OK permissions is good : -rw-rwSrw-<br />
test 10 folder  permissions 2666<br />
OK permissions is good : drw-rwSrw-<br />
test 11 file  permissions u+s<br />
OK permissions is good : -rwSr--r--<br />
test 12 file  permissions ug+s<br />
OK permissions is good : -rwSr-Sr--<br />
<br />
#===== test_acl	===================================<br />
test 13 file  acl<br />
OK same user id : proxy<br /> 
OK same grp id : proxy <br />
test 14 folder acl<br />
OK same user id : proxy <br />
OK same grp id : proxy <br />
<br />
#====== test_dates ===============================<br />
test 15 file mtime<br />
OK mtime is good : 1325372400<br />
test 16 file mtime in the futur<br />
OK mtime is good : 10325314800<br />
test 17 file mtime is negative<br />
OK mtime is good : -21231590961<br />
test 18 folder mtime<br />
OK mtime is good : 1325372400<br />
test 19 file atime<br />
OK mtime is good : 1325372400 <br />
test 20 folder atime<br />
OK mtime is good : 1325372400 <br />
<br />
#====== test_links	=============================<br />
test 21 symlink permissions<br />
OK same user id news<br />
OK same grp id : uucp<br />
test 22 file hardlink<br />
OK 3 hard link<br />
test 23 file symlink<br />
OK sym link<br />
test 24 folder symlink<br />
OK sym link<br />
test 25 invalid looped symlink<br />
OK symlink exists <br />
test 26 folder symlink loop<br />
OK symlink exists <br />
<br />
#====== test_specialdevices	==============================<br />
test 27 character device<br />
OK type is good : c<br />
OK major : 3<br />
OK minor : 2<br />
test 28 character device<br />
OK type is good : c<br />
OK major : 3<br />
OK minor : 3<br />
test 29 character device<br />
OK type is good : b<br />
OK major : 1<br />
OK minor : 0<br />
test 30 fifo<br />
OK , fifo ,p<br />
<br />
#===== test_xattrs	===========================<br />
test 31 file  xattrs<br />
OK same xattrs : this is a test<br />
test 32 folder xattrs<br />
OK same xattrs : this is a test<br />
<br />
#===== test_bincopy	===========================<br />
test 33 md5sum of ls -lk /bin copy<br />
OK same md5 399d70d2aad1e0cd817f9b34bdf6d7e1 *-<br />
test 34 md5sum of ls -lk /bin copy , exclude hardlink count<br />
OK same md5 8194aa7721cd48baccbf5cf9430a16a9 *-<br />
<br />
#======= test_highvalues	==============================<br />
test 35 254 char filename<br />
OK long filename exists<br />
test 36 254 folder name<br />
OK long folder exists<br />
test 37  254 char filename in 254 folder name<br />
OK long filename exists<br />
test 38 2048 files in folder<br />
OK all files present<br />
test 39 2048 folders in folder<br />
OK all folders<br />
test 40 100 subfolders levels<br />
OK all folders<br />
<br />
#======= test_onefileperuser	==========================<br />
test 41 1 file per user in passwd<br />
OK  good ownership<br />
test 42 1 file per user in passwd in one folder per user<br />
OK  good ownership<br />
<br />
#====== test_sparsefile	=============================<br />
test 43 totally sparse file<br />
OK file is sparse 0 10240<br />
test 44 partially sparse file <br />
OK file is partially sparse 1908 2683<br />
<br />
