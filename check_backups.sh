#!/bin/bash
#set -x
PREFIX=/tmp/filetests/
mkdir -p "$PREFIX"
TESTNUM="0"
cd "$PREFIX"
BACKUP_CMD="urbackupclientctl  start -i"
RESTORE_CMD="urbackupclientctl restore-start -b last -d filetests"


#======================================
function testit {
	if	[ "$MODE" = "READ" ]
	then
		return 1
	elif 	[ "$MODE" = "WRITE" ]
	then
		return 0
	else
		echo "invalid parameter, exiting"
		exit 1
	fi
}
function setup_testenv {

        echo -e "\n#===== setting up env ================================="

	if [ -z "$1" ]
	then
		echo "please specify READ, WRITE, LIST, DELETE, RESTORE, BACKUP"
		exit 1
	elif [ "$1" = "READ" ]
	then
		echo "=========WRITE MODE"
	elif [ "$1" = "WRITE" ]
	then
		echo "=========READ MODE"
	elif [ "$1" = "LIST" ]
	then
		       ls -l --color "$PREFIX"
	elif    [ "$1" = "DELETE" ]
	then
		echo "deleting $PREFIX"
		chattr -i "$PREFIX/"* 2>/dev/null
		rm -rf "$PREFIX"
		exit 0
	elif    [ "$1" = "BACKUP" ]
	then
		echo "backuping $PREFIX"
		$BACKUP_CMD
		exit 0

	elif    [ "$1" = "RESTORE" ]
	then
		echo "restoring $PREFIX"
		$RESTORE_CMD
		exit 0
	else
		echo "unsupported, exiting"
		exit 1
	fi

	MODE="$1"

	if testit
	then
		rm -rf "$PREFIX"
		echo "removed $PREFIX"
	fi

	mkdir -p "$PREFIX"
	echo "created $PREFIX"

	if [ ! -d "$PREFIX" ]
	then
		echo "missing $PREFIX , exiting"
		exit 1
	fi	
}

function test_users {
echo -e "\n#=====test_users ================================="
	TESTNUM="$(( $TESTNUM + 1))"
	TESTFILE="$PREFIX/test$TESTNUM"
	REFID="50123"
	echo "test $TESTNUM :file,  user doesn t exist locally"

	if testit
	then
		getent passwd "$REFID"
		RES="$?"
		if [[ "$RES" -eq "0" ]]
		then
			echo "userid exist, test wont be good"
		fi

		getent group "$REFID"
		RES="$?"
		if [[ "$RES" -eq "0" ]]
		then
		        echo "grpid exist, test won t be good"
		fi

		> "$TESTFILE"
		chown "$REFID:$REFID" "$TESTFILE"
		echo "created $TESTFILE"
	else
		USR="$(ls -ld "$TESTFILE" | awk '{print $3}')"
		if [[ "$USR" -ne "$REFID" ]]
		then
			echo "KO user id is different $USR != $REFID"
		else 
			echo "OK same grp id : $USR"
		fi

		GRP="$(ls -ld "$TESTFILE" | awk '{print $4}')"
			if [[ "$GRP" -ne "$REFID" ]]
		then
			echo "KO group id is different $GRP != $REFID"
		else
			echo "OK same grp id : $GRP"
		fi
	fi
	#=======================================
	TESTNUM="$(( $TESTNUM + 1))"
	TESTFILE="$PREFIX/test$TESTNUM"
	REFID="50123"
	echo "test $TESTNUM : folder user don t exist locally"

	if testit
	then
		getent passwd "$REFID"
		RES="$?"
		if [[ "$RES" -eq "0" ]]
		then
		        echo "userid exist, test wont be good"
		fi

		getent group "$REFID"
		RES="$?"
		if [[ "$RES" -eq "0" ]]
		then
		        echo "grpid exist, test won t be good"
		fi

		mkdir "$TESTFILE"
		chown "$REFID:$REFID" "$TESTFILE"
		echo "created $TESTFILE"
	else
		USR="$(ls -ld "$TESTFILE" | awk '{print $3}')"
		if [[ "$USR" -ne "$REFID" ]]
		then
		        echo "KO user id is different $USR != $REFID"
		else
		        echo "OK same user id : $USR"
		fi

		GRP="$(ls -ld "$TESTFILE" | awk '{print $4}')"
		        if [[ "$GRP" -ne "$REFID" ]]
		then
		        echo "KO group id is different $GRP != $REFID"
		else
		        echo "OK same grp id : $GRP"
		fi
	fi

	#=======================================
	TESTNUM="$(( $TESTNUM + 1))"
	echo "test $TESTNUM file,  10th  user, 11th group"
	TESTFILE="$PREFIX/test$TESTNUM"

	#       NUMUSER="(wc -l /etc/passwd)"
	#       RAND="$(( ( RANDOM % $NUMUSER )  + 1 ))"
	#       USR="$(sed "${$RAND}q;d" /etc/passwd | awk '{print $1}')"
	USR="$(sed "10q;d" /etc/passwd | cut -d ':' -f 1)"
	GRP="$(sed "11q;d" /etc/group  | cut -d ':' -f 1 )"

	if testit
	then
		>"$TESTFILE"
		chown "$USR:$GRP" "$TESTFILE"
			echo "created $TESTFILE"
	else
		USRB="$(ls -ld "$TESTFILE" | awk '{print $3}')"
		if [ "$USR" != "$USRB" ]
		then
		        echo "KO user id is different exptected $USR got  $USRB"
		else 
		        echo "OK same user id $USR"
		fi

		GRPB="$(ls -ld "$TESTFILE" | awk '{print $4}')"
		if [ "$GRP" != "$GRPB" ]
		then
		        echo "KO group id is different expected $GRP got $GRPB"
		else
		        echo "OK same grp id : $GRP"
		fi
	fi
	#=======================================
	TESTNUM="$(( $TESTNUM + 1))"
	echo "test $TESTNUM file,  last passwd user id"
	TESTFILE="$PREFIX/test$TESTNUM"

	#       NUMUSER="(wc -l /etc/passwd)"
	#       RAND="$(( ( RANDOM % $NUMUSER )  + 1 ))"
	#       USR="$(sed "${$RAND}q;d" /etc/passwd | awk '{print $1}')"
	USR="$(tail -n1  /etc/passwd | cut -d ':' -f 1)"
	GRP="$(tail -n1  /etc/group  | cut -d ':' -f 1 )"

	if testit
	then
		>"$TESTFILE"
		chown "$USR:$GRP" "$TESTFILE"
		        echo "created $TESTFILE"
	else
		USRB="$(ls -ld "$TESTFILE" | awk '{print $3}')"
		if [ "$USR" != "$USRB" ]
		then
		        echo "KO user id is different $USR != $USRB"
		else
		        echo "OK same user id $USR"
		fi

		GRPB="$(ls -ld "$TESTFILE" | awk '{print $4}')"
		        if [ "$GRP" != "$GRPB" ]
		then
		        echo "KO group id is different $GRP != $GRPB"
		else
		        echo "OK same grp id : $GRP"
		fi
	fi

	#=======================================
	TESTNUM="$(( $TESTNUM + 1))"
	echo "test $TESTNUM folder, random user"
	TESTFILE="$PREFIX/test$TESTNUM"

	USR="$(sed "10q;d" /etc/passwd | cut -d ':' -f 1)"
	GRP="$(sed "11q;d" /etc/group  | cut -d ':' -f 1 )"

	if testit
	then
		mkdir "$TESTFILE"
		chown "$USR:$GRP" "$TESTFILE"
		        echo "created $TESTFILE"
	else
		USRB="$(ls -ld "$TESTFILE" | awk '{print $3}')"
		if [ "$USR" != "$USRB" ]
		then
		        echo "KO user id is different $USR != $USRB"
		else
		        echo "OK same user id $USR"
		fi

		GRPB="$(ls -ld "$TESTFILE" | awk '{print $4}')"
		        if [ "$GRP" != "$GRPB" ]
		then
		        echo "KO group id is different $GRP != $GRPB"
		else
		        echo "OK same grp id : $GRP"
		fi
	fi
	#=======================================
	TESTNUM="$(( $TESTNUM + 1))"
	echo "test $TESTNUM folder, last passwd user id"
	TESTFILE="$PREFIX/test$TESTNUM"

	USR="$(tail -n1 /etc/passwd | cut -d ':' -f 1)"
	GRP="$(tail -n1 /etc/group  | cut -d ':' -f 1 )"

	if testit
	then
		mkdir "$TESTFILE"
		chown "$USR:$GRP" "$TESTFILE"
		        echo "created $TESTFILE"
	else
		USRB="$(ls -ld "$TESTFILE" | awk '{print $3}')"
		if [ "$USR" != "$USRB" ]
		then
		        echo "KO user id is different $USR != $USRB"
		else
		        echo "OK same user id $USR"
		fi

		GRPB="$(ls -ld "$TESTFILE" | awk '{print $4}')"
		        if [ "$GRP" != "$GRPB" ]
		then
		        echo "KO group id is different $GRP != $GRPB"
		else
		        echo "OK same grp id : $GRP"
		fi
	fi

}





function test_permissions {
	
echo -e "\n#===== test_permissions	==================================="
	TESTNUM="$(( $TESTNUM + 1))"
	echo "test $TESTNUM  file permissions 444"
	TESTFILE="$PREFIX/test$TESTNUM"
	PERM="444"
	PERMB="-r--r--r--"
	if testit
	then
		>"$TESTFILE"
		chmod "$PERM" "$TESTFILE"
	else
		PERMC="$(stat -c %A "$TESTFILE")"
		if [[ "$PERMB" = "$PERMC" ]]
		then
		        echo "OK permissions is good : $PERMB"
		else
		        echo "KO permission is bad $PERMB != $PERMC"
		fi
	fi

	#=======================================
	TESTNUM="$(( $TESTNUM + 1))"
	echo "test $TESTNUM  folder permissions 444"
	TESTFILE="$PREFIX/test$TESTNUM"
	PERM="444"
	PERMB="dr--r--r--"
	if testit
	then
	      mkdir  "$TESTFILE"
		chmod "$PERM" "$TESTFILE"
	else
		PERMC="$(stat -c %A "$TESTFILE")"
		if [[ "$PERMB" = "$PERMC" ]]
		then
		        echo "OK permissions is good : $PERMB"
		else
		        echo "KO permission is bad $PERMB != $PERMC"
		fi
	fi

	#=======================================
	TESTNUM="$(( $TESTNUM + 1))"
	echo "test $TESTNUM file  permissions 2666"
	TESTFILE="$PREFIX/test$TESTNUM"
	PERM="2666"
	PERMB="-rw-rwSrw-"
	if testit
	then
		>"$TESTFILE"
		chmod "$PERM" "$TESTFILE"
	else
		PERMC="$(stat -c %A "$TESTFILE")"
		if [[ "$PERMB" = "$PERMC" ]]
		then
		        echo "OK permissions is good : $PERMB"
		else
		        echo "KO permission is bad $PERMB != $PERMC"
		fi
	fi

	#=======================================
	TESTNUM="$(( $TESTNUM + 1))"
	echo "test $TESTNUM folder  permissions 2666"
	TESTFILE="$PREFIX/test$TESTNUM"
	PERM="2666"
	PERMB="drw-rwSrw-"
	if testit
	then
		mkdir "$TESTFILE"
		chmod "$PERM" "$TESTFILE"
	else
		PERMC="$(stat -c %A "$TESTFILE")"
		if [[ "$PERMB" = "$PERMC" ]]
		then
		        echo "OK permissions is good : $PERMB"
		else
		        echo "KO permission is bad $PERMB != $PERMC"
		fi
	fi

	#=======================================
	TESTNUM="$(( $TESTNUM + 1))"
	echo "test $TESTNUM file  permissions u+s"
	TESTFILE="$PREFIX/test$TESTNUM"
	PERM="4644"
	PERMB="-rwSr--r--"
	if testit
	then
		> "$TESTFILE"
		chmod "$PERM" "$TESTFILE"
	else
		PERMC="$(stat -c %A "$TESTFILE")"
		if [[ "$PERMB" = "$PERMC" ]]
		then
		        echo "OK permissions is good : $PERMB"
		else
		        echo "KO permission is bad $PERMB != $PERMC"
		fi
	fi

	#=======================================
	TESTNUM="$(( $TESTNUM + 1))"
	echo "test $TESTNUM file  permissions ug+s"
	TESTFILE="$PREFIX/test$TESTNUM"
	PERM="6644"
	PERMB="-rwSr-Sr--"
	if testit
	then
		> "$TESTFILE"
		chmod "$PERM" "$TESTFILE"
	else
		PERMC="$(stat -c %A "$TESTFILE")"
		if [[ "$PERMB" = "$PERMC" ]]
		then
		        echo "OK permissions is good : $PERMB"
		else
		        echo "KO permission is bad $PERMB != $PERMC"
		fi
	fi

}

function test_acl {
echo -e "\n#===== test_acl	==================================="
	TESTNUM="$(( $TESTNUM + 1))"
	echo "test $TESTNUM file  acl"
	TESTFILE="$PREFIX/test$TESTNUM"

		USR="$(sed "12q;d" /etc/passwd |cut -d ':' -f1)"
		GRP="$(sed "13q;d" /etc/group  | cut -d ':' -f1)"

	if testit
	then
	#        NUMUSER="(wc -l /etc/passwd)"
	#       RAND="$(( ( RANDOM % $NUMUSER )  + 1 ))"
	#       USR="$(sed "${$RAND}q;d" /etc/passwd | awk '{print $1}')"

		>"$TESTFILE"
		setfacl -m u:$USR:r "$TESTFILE" 
		setfacl -m g:$GRP:r "$TESTFILE"
		echo "created $TESTFILE"
	else

		USRB="$(getfacl -pe "$TESTFILE"| grep "^user:$USR:r--"| cut -d ':' -f 2)"
		if [ "$USR" != "$USRB" ]
		then
		        echo "KO user id is different $USRB != $USR"
		else
		        echo "OK same user id : $USRB "
		fi

		GRPB="$(getfacl -pe "$TESTFILE"| grep "^group:$GRP:r--"| cut -d ':' -f 2)"
		if [ "$GRP" != "$GRPB" ]
		then
		        echo "KO group id is different $GRPB != $GRP"
		else
		        echo "OK same grp id : $GRPB "
		fi
	fi

	#=======================================
	TESTNUM="$(( $TESTNUM + 1))"
	echo "test $TESTNUM folder acl"
	TESTFILE="$PREFIX/test$TESTNUM"

		USR="$(sed "12q;d" /etc/passwd |cut -d ':' -f1)"
		GRP="$(sed "13q;d" /etc/group  | cut -d ':' -f1)"

	if testit
	then
	#        NUMUSER="(wc -l /etc/passwd)"
	#       RAND="$(( ( RANDOM % $NUMUSER )  + 1 ))"
	#       USR="$(sed "${$RAND}q;d" /etc/passwd | awk '{print $1}')"

		mkdir "$TESTFILE"
		setfacl -m u:$USR:r "$TESTFILE"
		setfacl -m g:$GRP:r "$TESTFILE"
		echo "created $TESTFILE"
	else

		USRB="$(getfacl -pe "$TESTFILE"| grep "^user:$USR:r--"| cut -d ':' -f 2)"
		if [ "$USR" != "$USRB" ]
		then
		        echo "KO user id is different $USRB != $USR"
		else
		        echo "OK same user id : $USRB "
		fi

		GRPB="$(getfacl -pe "$TESTFILE"| grep "^group:$GRP:r--"| cut -d ':' -f 2)"
		if [ "$GRP" != "$GRPB" ]
		then
		        echo "KO group id is different $GRPB != $GRP"
		else
		        echo "OK same grp id : $GRPB "
		fi
	fi
}


function test_chattrs {
	echo -e "\n#===== test_chattr =================================="
        TESTNUM="$(( $TESTNUM + 1))"
        echo "test $TESTNUM file chattrs"
        TESTFILE="$PREFIX/test$TESTNUM"
	ATTR="-i-----j-t-e----"

	#i immutable
	#j journal writes
	#S sync files
	#t disable tail merging

        if testit
        then
                chattr -i "$TESTFILE" 2> /dev/null
                > "$TESTFILE"
                echo "created $TESTFILE"
		chattr +ijSt "$TESTFILE"
	else
                RES="$( lsattr  "$TESTFILE")"
		if [ "$ATTR" = "$RES" ]
                then
                        echo "KO attr is different $ATTR != $RES"
                else
                        echo "OK same attr : $ATTR "
                fi
        fi

        #=======================================
        TESTNUM="$(( $TESTNUM + 1))"
        echo "test $TESTNUM folder chattrs"
        TESTFILE="$PREFIX/test$TESTNUM"
	ATTR="---D--d------Te---P"

	#d disable dump
	#P project hierarchy
	#D sync folders #folder only
	#T top level for block alocator

        if testit
        then
                mkdir "$TESTFILE"
                echo "created $TESTFILE"
                chattr +dPDT "$TESTFILE"
        else
		RES="$( lsattr -d "$TESTFILE")"
                if [ "$ATTR" = "$RES" ]
                then
                        echo "KO attr is different $ATTR != $RES"
                else
                        echo "OK same attr : $ATTR "
                fi
        fi
}

function test_dates {
echo -e "\n#====== test_dates ==============================="
	TESTNUM="$(( $TESTNUM + 1))"
	echo "test $TESTNUM file mtime"
	TESTFILE="$PREFIX/test$TESTNUM"
	TDATE="20120101"
	TDATEB="1325372400"
	if testit
	then
		>"$TESTFILE"
		touch -d "$TDATE" "$TESTFILE"
	else
		FDATE="$(stat -c %Y "$TESTFILE")"
		if [[ "$FDATE" = "$TDATEB" ]]
		then
			echo "OK mtime is good : $FDATE"
		else
			echo "KO mtime is bad $FDATE != $TDATEB"
		fi
	fi

	#=======================================
	TESTNUM="$(( $TESTNUM + 1))"
	echo "test $TESTNUM file mtime in the futur"
	TESTFILE="$PREFIX/test$TESTNUM"
	TDATE="22970313"
	TDATEB="10325314800"
	if testit
	then
		>"$TESTFILE"
		touch -d "$TDATE" "$TESTFILE"
	else
		FDATE="$(stat -c %Y "$TESTFILE")"
		if [[ "$FDATE" = "$TDATEB" ]]
		then
		        echo "OK mtime is good : $FDATE"
		else
		        echo "KO mtime is bad $FDATE != $TDATEB"
		fi
	fi

	#=======================================
	TESTNUM="$(( $TESTNUM + 1))"
	echo "test $TESTNUM file mtime is negative"
	TESTFILE="$PREFIX/test$TESTNUM"
	TDATE="12970313"
	TDATEB="-21231590961"
	if testit
	then
		>"$TESTFILE"
		touch -d "$TDATE" "$TESTFILE"
	else
		FDATE="$(stat -c %Y "$TESTFILE")"
		if [[ "$FDATE" = "$TDATEB" ]]
		then
		        echo "OK mtime is good : $FDATE"
		else
		        echo "KO mtime is bad $FDATE != $TDATEB"
		fi
	fi

	#=======================================
	TESTNUM="$(( $TESTNUM + 1))"
	echo "test $TESTNUM folder mtime"
	TESTFILE="$PREFIX/test$TESTNUM"
	TDATE="20120101"
	TDATEB="1325372400"
	if testit
	then
		mkdir  "$TESTFILE"
		touch -d "$TDATE" "$TESTFILE"
	else
		FDATE="$(stat -c %Y "$TESTFILE")"
		if [[ "$FDATE" = "$TDATEB" ]]
		then
		        echo "OK mtime is good : $FDATE"
		else
		        echo "KO mtime is bad $FDATE != $TDATEB"
		fi
	fi
	#=======================================
	TESTNUM="$(( $TESTNUM + 1))"
	echo "test $TESTNUM file atime"
	TESTFILE="$PREFIX/test$TESTNUM"
	TDATE="20120101"
	TDATEB="1325372400"
	if testit
	then
		>"$TESTFILE"
		touch -c -d "$TDATE" "$TESTFILE"
	else
		FDATE="$(stat -c %X "$TESTFILE")"
		if [[ "$FDATE" = "$TDATEB" ]]
		then
		        echo "OK mtime is good : $FDATE "
		else
		        echo "KO mtime is bad $FDATE != $TDATEB"
		fi
	fi

	#=======================================
	TESTNUM="$(( $TESTNUM + 1))"
	echo "test $TESTNUM folder atime"
	TESTFILE="$PREFIX/test$TESTNUM"
	TDATE="20120101"
	TDATEB="1325372400"
	if testit
	then
		mkdir "$TESTFILE"
		touch -c -d "$TDATE" "$TESTFILE"
	else
		FDATE="$(stat -c %X "$TESTFILE")"
		if [[ "$FDATE" = "$TDATEB" ]]
		then
		        echo "OK mtime is good : $FDATE "
		else
		        echo "KO mtime is bad $FDATE != $TDATEB"
		fi
	fi

}



function test_links {
echo -e "\n#====== test_links	============================="
	TESTNUM="$(( $TESTNUM + 1))"
	echo "test $TESTNUM symlink permissions"
	TESTFILE="$PREFIX/test$TESTNUM"

	#       NUMUSER="(wc -l /etc/passwd)"
	#       RAND="$(( ( RANDOM % $NUMUSER )  + 1 ))"
	#       USR="$(sed "${$RAND}q;d" /etc/passwd | awk '{print $1}')"
	USR="$(sed "10q;d" /etc/passwd | cut -d ':' -f 1)"
	GRP="$(sed "11q;d" /etc/group  | cut -d ':' -f 1 )"

	if testit
	then
		>"$TESTFILE"
		ln -s "$TESTFILE" "${TESTFILE}_slink"
			chown -h "$USR:$GRP" "${TESTFILE}_slink"
		        echo "created $TESTFILE"
	else
		USRB="$(ls -ld "${TESTFILE}_slink" | awk '{print $3}')"
		if [ "$USR" != "$USRB" ]
		then
		        echo "KO user id is different exptected $USR got  $USRB"
		else
		        echo "OK same user id $USR"
		fi

		GRPB="$(ls -ld "${TESTFILE}_slink" | awk '{print $4}')"
		if [ "$GRP" != "$GRPB" ]
		then
		        echo "KO group id is different expected $GRP got $GRPB"
		else
		        echo "OK same grp id : $GRP"
		fi
	fi

	#=======================================
	TESTNUM="$(( $TESTNUM + 1))"
	echo "test $TESTNUM file hardlink"
	TESTFILE="$PREFIX/test$TESTNUM"

	if testit
	then
		>"$TESTFILE"
		ln "$TESTFILE" "${TESTFILE}_hlink1"
		ln "$TESTFILE" "${TESTFILE}_hlink2"
	else
	       HLINK="$(stat -c %h "$TESTFILE")"
		if [[ "$HLINK" -eq "3" ]]
		then
		        echo "OK 3 hard link"
		else
		        echo "KO $HLINK hardlink != 3"
		fi
	fi

	#=======================================
	TESTNUM="$(( $TESTNUM + 1))"
	echo "test $TESTNUM file symlink"
	TESTFILE="$PREFIX/test$TESTNUM"

	if testit
	then
		>"$TESTFILE"
		ln -s "$TESTFILE" "${TESTFILE}_slink1"
	else
		if [ -L "${TESTFILE}_slink1" ]
		then
		        echo "OK sym link"
		else
		        echo "KO not symlink"
		fi
	fi
	#=======================================
	TESTNUM="$(( $TESTNUM + 1))"
	echo "test $TESTNUM folder symlink"
	TESTFILE="$PREFIX/test$TESTNUM"

	if testit
	then
		mkdir "$TESTFILE"
		ln -s "$TESTFILE" "${TESTFILE}_slink1"
	else
		if [ -L "${TESTFILE}_slink1" ]
		then
		        echo "OK sym link"
		else
		        echo "KO not symlink"
		fi
	fi
	#=======================================
	TESTNUM="$(( $TESTNUM + 1))"
	echo "test $TESTNUM invalid looped symlink"
	TESTFILE="$PREFIX/test${TESTNUM}"

	if testit
	then
	      > "$TESTFILE"
		ln -s "$TESTFILE" "${TESTFILE}_ln1"
		ln -s "${TESTFILE}_ln1" "${TESTFILE}_ln2"
		rm -f "$TESTFILE"
		ln -s "${TESTFILE}_ln1" "$TESTFILE" 
	else

		if [ -L "$TESTFILE" ] && [ -L "${TESTFILE}_ln1" ] && [ -L "${TESTFILE}_ln2" ]
		then
		        echo "OK symlink exists "
		else
		        echo "KO symlink absent"
		fi
	fi

	#=======================================
	TESTNUM="$(( $TESTNUM + 1))"
	echo "test $TESTNUM folder symlink loop"
	TESTFILE="$PREFIX/test${TESTNUM}"

	if testit
	then
	      cd "$PREFIX"
		mkdir "$TESTFILE"
		cd "$TESTFILE"
		 ln -s "../test${TESTNUM}" "./test${TESTNUM}"
	else

		if [ -d "$TESTFILE" ] && [ -L "$TESTFILE/test${TESTNUM}" ] && [ -L "$TESTFILE/test${TESTNUM}/test${TESTNUM}" ]
		then
		        echo "OK symlink exists "
		else
		        echo "KO symlink absent"
		fi
	fi

}


function test_specialdevices {

echo -e "\n#====== test_specialdevices	=============================="
	TESTNUM="$(( $TESTNUM + 1))"
	echo "test $TESTNUM character device"
	TESTFILE="$PREFIX/test$TESTNUM"
	MAJ="3"
	MIN="2"
	TYPE="c"
	if testit
	then
		mknod "$TESTFILE" "$TYPE" "$MAJ" "$MIN"
	else
		TYPEB="$(ls -ld "$TESTFILE"| cut -c 1)"
		if [[ "$TYPE" = "$TYPEB" ]]
		then
		        echo "OK type is good : $TYPE"
		else
		        echo "KO type is bad $TYPE != $TYPEB"
		fi

		MAJB="$(stat -c %t "$TESTFILE")"
		if [[ "$MAJB" = "$MAJ" ]]
		then
		        echo "OK major : $MAJB"
		else
		        echo "KO major $MAJB != $MAJ"
		fi

		MINB="$(stat -c %T "$TESTFILE")"
		if [[ "$MINB" = "$MIN" ]]
		then
		        echo "OK minor : $MINB"
		else
		        echo "KO minor $MINB != $MIN"
		fi
	fi

	#=======================================
	TESTNUM="$(( $TESTNUM + 1))"
	echo "test $TESTNUM character device"
	TESTFILE="$PREFIX/test$TESTNUM"
	MAJ="3"
	MIN="3"
	TYPE="c"
	if testit
	then
		mknod "$TESTFILE" "$TYPE" "$MAJ" "$MIN"
	else
		TYPEB="$(ls -ld "$TESTFILE"| cut -c 1)"
		if [[ "$TYPE" = "$TYPEB" ]]
		then
		        echo "OK type is good : $TYPE"
		else
		        echo "KO type is bad $TYPE != $TYPEB"
		fi

		MAJB="$(stat -c %t "$TESTFILE")"
		if [[ "$MAJB" = "$MAJ" ]]
		then
		        echo "OK major : $MAJB"
		else
		        echo "KO major $MAJB != $MAJ"
		fi

		MINB="$(stat -c %T "$TESTFILE")"
		if [[ "$MINB" = "$MIN" ]]
		then
		        echo "OK minor : $MINB"
		else
		        echo "KO minor $MINB != $MIN"
		fi
	fi
	#=======================================
	TESTNUM="$(( $TESTNUM + 1))"
	echo "test $TESTNUM character device"
	TESTFILE="$PREFIX/test$TESTNUM"
	MAJ="1"
	MIN="0"
	TYPE="b"
	if testit
	then
		mknod "$TESTFILE" "$TYPE" "$MAJ" "$MIN"
	else
		TYPEB="$(ls -ld "$TESTFILE"| cut -c 1)"
		if [[ "$TYPE" = "$TYPEB" ]]
		then
		        echo "OK type is good : $TYPE"
		else
		        echo "KO type is bad $TYPE != $TYPEB"
		fi

		MAJB="$(stat -c %t "$TESTFILE")"
		if [[ "$MAJB" = "$MAJ" ]]
		then
		        echo "OK major : $MAJB"
		else
		        echo "KO major $MAJB != $MAJ"
		fi

		MINB="$(stat -c %T "$TESTFILE")"
		if [[ "$MINB" = "$MIN" ]]
		then
		        echo "OK minor : $MINB"
		else
		        echo "KO minor $MINB != $MIN"
		fi
	fi
	#=======================================
	TESTNUM="$(( $TESTNUM + 1))"
	echo "test $TESTNUM fifo"
	TESTFILE="$PREFIX/test$TESTNUM"

	if testit
	then
		mkfifo "$TESTFILE"
	else
		TYPE="$(ls -ld "$TESTFILE" | cut -c1)"
		if [ "$TYPE" == "p" ]
		then
		        echo "OK , fifo ,$TYPE"
		else
		        echo "KO  not a fifo $TYPE"
		fi
	fi
}

function test_xattrs {

echo -e "\n#===== test_xattrs	==========================="
	TESTNUM="$(( $TESTNUM + 1))"
	echo "test $TESTNUM file  xattrs"
	TESTFILE="$PREFIX/test$TESTNUM"
	TXT="this is a test"
	ATTR="user.testing"

	if testit
	then
		>"$TESTFILE"
		setfattr -n "$ATTR" -v "$TXT" "$TESTFILE"
	else
		RES="$(getfattr --absolute-names --only-values -n "$ATTR" "$TESTFILE")"
		if [ "$RES" == "$TXT" ]
		then
		        echo "OK same xattrs : $RES"
		else
		        echo "KO different xattrs $RES != $TXT"
		fi
	fi

	#=======================================
	TESTNUM="$(( $TESTNUM + 1))"
	echo "test $TESTNUM folder xattrs"
	TESTFILE="$PREFIX/test$TESTNUM"
	TXT="this is a test"
	ATTR="user.testing"

	if testit
	then
		mkdir "$TESTFILE"
		setfattr -n "$ATTR" -v "$TXT" "$TESTFILE"
	else
		RES="$(getfattr --absolute-names --only-values -n "$ATTR" "$TESTFILE")"
		if [ "$RES" == "$TXT" ]
		then
		        echo "OK same xattrs : $RES"
		else
		        echo "KO different xattrs $RES != $TXT"
		fi
	fi

}


function test_filenames {
echo -e "\n#====== test_filenames	============================="
	TESTNUM="$(( $TESTNUM + 1))"
	echo "test $TESTNUM file special filename : _éèçàùù=+-ç-()61aze¨£€#,x az~"
	#test31_éèçàùù=+-ç-()61aze¨£€#,x az~
	SPEC="$(printf "\xc3\xa9\xc3\xa8\xc3\xa7\xc3\xa0\xc3\xb9\xc3\xb9\x3d\x2b\x2d\xc3\xa7\x2d\x28\x29\x36\x31\x61\x7a\x65\xc2\xa8\xc2\xa3\xe2\x82\xac\x23\x2c\x78\x20\x61\x7a\x7e")"
	TESTFILE="$PREFIX/test${TESTNUM}_${SPEC}"

	if testit
	then
		> "$TESTFILE"
	else
		if [  "$TESTFILE" ]
		then
		        echo "OK file exists $TESTFILE"
		else
		        echo "KO file absent $TESTFILE"
		fi
	fi

	#=======================================
	TESTNUM="$(( $TESTNUM + 1))"
	echo "test $TESTNUM file special filename :     :*?"
	SPEC="$(printf "\x3f\x0a\x2a\x0a\x3a\x0a")"
	TESTFILE="$PREFIX/test${TESTNUM}_${SPEC}"

	if testit
	then
		> "$TESTFILE"
	else
		if [  "$TESTFILE" ]
		then
		        echo "OK file exists $TESTFILE"
		else
		        echo "KO file absent $TESTFILE"
		fi
	fi

	#=======================================
	TESTNUM="$(( $TESTNUM + 1))"
	echo "test $TESTNUM file special filename :  '^&"'@{}[]$!%'
	SPEC="$(printf "\x27\x5e\x26\x40\x7b\x7d\x5b\x5d\x24\x21\x25\x0a")"
	TESTFILE="$PREFIX/test${TESTNUM}_${SPEC}"

	if testit
	then
		> "$TESTFILE"
	else
		if [  "$TESTFILE" ]
		then
		        echo "OK file exists $TESTFILE"
		else
		        echo "KO file absent $TESTFILE"
		fi
	fi


	#=======================================
	TESTNUM="$(( $TESTNUM + 1))"
	echo "test $TESTNUM file newline in filename"
	SPEC="aaaa
	bbb
	ccccc"
	TESTFILE="$PREFIX/test${TESTNUM}_${SPEC}"

	if testit
	then
		> "$TESTFILE"
	else
		if [  "$TESTFILE" ]
		then
		        echo "OK file exists $TESTFILE"
		else
		        echo "KO file absent $TESTFILE"
		fi
	fi

	#=======================================
	TESTNUM="$(( $TESTNUM + 1))"
	echo "test $TESTNUM folder special filename"
	SPEC="$(printf "\xc3\xa9\xc3\xa8\xc3\xa7\xc3\xa0\xc3\xb9\xc3\xb9\x3d\x2b\x2d\xc3\xa7\x2d\x28\x29\x36\x31\x61\x7a\x65\xc2\xa8\xc2\xa3\xe2\x82\xac\x23\x2c\x78\x20\x61\x7a\x7e")"
	TESTFILE="$PREFIX/test${TESTNUM}_${SPEC}"

	if testit
	then
		mkdir "$TESTFILE"
	else
		if [ -d "$TESTFILE" ]
		then
		        echo "OK folder exists $TESTFILE"
		else
		        echo "KO folder absent $TESTFILE"
		fi
	fi
}


function test_bincopy {


echo -e "\n#===== test_bincopy	==========================="
	TESTNUM="$(( $TESTNUM + 1))"
	echo "test $TESTNUM md5sum of ls -lk /bin copy"
	TESTFILE="$PREFIX/test${TESTNUM}"
	ORIG="$(ls -lk "/bin/" | tail -n +2 | md5sum -b)"

	if grep -q /tmp /etc/mtab
	then
		"echo different fs, will fail because of hardlink count"
	fi

	if testit
	then
		mkdir "$TESTFILE"
		cp -ab /bin/* "$TESTFILE/"
		ls -lk "$TESTFILE" | tail -n +2 | md5sum -b
	else
		DEST="$(ls -lk "$TESTFILE" | tail -n +2| md5sum -b)"

		if [ "$ORIG" == "$DEST" ]
		then
		        echo "OK same md5 $ORIG"
		else
		        echo "KO different md5 $DEST != $ORIG"
		fi
	fi

	#=======================================

	TESTNUM="$(( $TESTNUM + 1))"
	echo "test $TESTNUM md5sum of ls -lk /bin copy , exclude hardlink count"
	TESTFILE="$PREFIX/test${TESTNUM}"
	ORIG="$(ls -lk "/bin/" | awk  '!($2="")' | tail -n +2 | md5sum -b)"


	if testit
	then
		mkdir "$TESTFILE"
		cp -ab /bin/* "$TESTFILE/"
		ls -lk "$TESTFILE"| awk  '!($2="")'  | tail -n +2|  md5sum -b
	else
		DEST="$(ls -lk "$TESTFILE"| tail -n +2| awk  '!($2="")' | md5sum -b)"

		if [ "$ORIG" == "$DEST" ]
		then
		        echo "OK same md5 $ORIG"
		else
		        echo "KO different md5 $DEST != $ORIG"
		fi
	fi
}

function test_highvalues {
echo -e "\n#======= test_highvalues	=============================="
	TESTNUM="$(( $TESTNUM + 1))"
	echo "test $TESTNUM 254 char filename"
	TESTFILE="$PREFIX/test${TESTNUM}"

	I=0
	L=254
	LNAME=""
	while [ $I -lt $L ]
	do
		I=$(( $I + 1 ))
		LNAME="${LNAME}a"
	done



	if testit
	then
		mkdir "$TESTFILE"
		> "$TESTFILE/$LNAME"
	else

		if [ -f "$TESTFILE/$LNAME" ]
		then
		        echo "OK long filename exists"
		else
		        echo "KO long filename is absent "
		fi
	fi

	#==========================================
	TESTNUM="$(( $TESTNUM + 1))"
	echo "test $TESTNUM 254 folder name"
	TESTFILE="$PREFIX/test${TESTNUM}"

	I=0
	L=254
	LNAME=""


	while [ $I -lt $L ]
	do
		I=$(( $I + 1 ))
		LNAME="${LNAME}a"
	done



	if testit
	then
		mkdir "$TESTFILE"
		mkdir "$TESTFILE/$LNAME"
	else

		if [ -d "$TESTFILE/$LNAME" ]
		then
		        echo "OK long folder exists"
		else
		        echo "KO long folder is absent "
		fi
	fi

	#==========================================
	TESTNUM="$(( $TESTNUM + 1))"
	echo "test $TESTNUM  254 char filename in 254 folder name"
	TESTFILE="$PREFIX/test${TESTNUM}"

	I=0
	L=254
	LNAME=""
	while [ $I -lt $L ]
	do
		I=$(( $I + 1 ))
		LNAME="${LNAME}a"
	done



	if testit
	then
		mkdir "$TESTFILE"
		mkdir "$TESTFILE/$LNAME"
		> "$TESTFILE/$LNAME/$LNAME"
	else

		if [ -f "$TESTFILE/$LNAME/$LNAME" ]
		then
		        echo "OK long filename exists"
		else
		        echo "KO long filename is absent "
		fi
	fi


	#==========================================
	TESTNUM="$(( $TESTNUM + 1))"
	echo "test $TESTNUM 2048 files in folder"

	TESTFILE="$PREFIX/test${TESTNUM}"

	I=0
	L=2048

	if testit
	then
		mkdir "$TESTFILE"
		while [ $I -lt $L ]
		do
			I=$(( $I + 1 ))
			>  "$TESTFILE/$I"
		done
	else
		FAIL=0
		while [ $I -lt $L ]
		do
		        I=$(( $I + 1 ))

			if [ ! -f "$TESTFILE/$I" ]
			then
				FAIL=1
			fi
		done

		if [ "$FAIL" -eq 1 ]
		then
		        echo "KO missing file"
		else
		        echo "OK all files present"
		fi
	fi

	#==========================================
	TESTNUM="$(( $TESTNUM + 1))"
	echo "test $TESTNUM 2048 folders in folder"

	TESTFILE="$PREFIX/test${TESTNUM}"

	I=0
	L=2048

	if testit
	then
		mkdir "$TESTFILE"
		while [ $I -lt $L ]
		do
		        I=$(( $I + 1 ))
		        mkdir  "$TESTFILE/$I"
		done
	else
		FAIL=0
		while [ $I -lt $L ]
		do
		        I=$(( $I + 1 ))

		        if [ ! -d "$TESTFILE/$I" ]
		        then
		                FAIL=1
		        fi
		done

		if [ "$FAIL" -eq 1 ]
		then
		        echo "KO missing folder"
		else
		        echo "OK all folders"
		fi
	fi

	#==========================================
	TESTNUM="$(( $TESTNUM + 1))"
	echo "test $TESTNUM 100 subfolders levels"

	TESTFILE="$PREFIX/test${TESTNUM}"
	FNAME="$TESTFILE/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a/a"


	if testit
	then
		mkdir -p "$FNAME"
	else
		if [ ! -d "$FNAME" ]
		then
		        echo "KO missing folder"
		else
		        echo "OK all folders"
		fi
	fi
}

function test_onefileperuser {

echo -e "\n#======= test_onefileperuser	=========================="
	TESTNUM="$(( $TESTNUM + 1))"
	echo "test $TESTNUM 1 file per user in passwd"

	TESTFILE="$PREFIX/test${TESTNUM}"
	USRS="$(cat /etc/passwd| cut -d ':' -f 1)"
	if testit
	then
		mkdir -p "$TESTFILE"

		for USR in $USRS
		do
			> "$TESTFILE/$USR"
			chown "$USR" "$TESTFILE/$USR"
		done
	else
		FAIL=0
		for USR in $USRS
		do
			TUSR="$(ls -ld  "$TESTFILE/$USR" | awk '{print $3}' )"
		        if [ "$TUSR" != "$USR" ]
			then
				FAIL=1
			fi

		        if [ ! -f  "$TESTFILE/$USR" ]
		        then
		                FAIL=1
		        fi

		done

		if [ "$FAIL" -eq 1 ]
		then
		        echo "KO bad ownership"
		else
		        echo "OK  good ownership"
		fi
	fi

	#==========================================
	TESTNUM="$(( $TESTNUM + 1))"
	echo "test $TESTNUM 1 file per user in passwd in one folder per user"

	TESTFILE="$PREFIX/test${TESTNUM}"
	USRS="$(cat /etc/passwd| cut -d ':' -f 1)"
	if testit
	then
		mkdir -p "$TESTFILE"

		for DUSR in $USRS
		do
			mkdir "$TESTFILE/$DUSR"
			chown "$DUSR" "$TESTFILE/$DUSR"

			for FUSR in $USRS
			do
			        > "$TESTFILE/$DUSR/$FUSR"
			        chown "$FUSR" "$TESTFILE/$DUSR/$FUSR"
			done
		done
	else
		FAIL=0

		for DUSR in $USRS
		do
		        TUSR="$(ls -ld  "$TESTFILE/$DUSR/" | awk '{print $3}' )"
		        if [ "$TUSR" != "$DUSR" ]
		        then
		        #               echo "$TUSR  != $FUSR"
		                FAIL=1
		        fi

		        if [ ! -d  "$TESTFILE/$DUSR" ]
		        then
		                FAIL=1
		        fi

			for FUSR in $USRS
			do
			        TUSR="$(ls -ld  "$TESTFILE/$DUSR/$FUSR" | awk '{print $3}' )"
			        if [ "$TUSR" != "$FUSR" ]
			        then
			#		echo "$TUSR  != $FUSR"
			                FAIL=1
			        fi

			        if [ ! -f  "$TESTFILE/$DUSR/$FUSR" ]
			        then
			#		echo "miss $TESTFILE/$DUSR/$FUSR"
			                FAIL=1
			        fi
			done
		done

		if [ "$FAIL" -eq 1 ]
		then
		        echo "KO bad ownership"
		else
		        echo "OK  good ownership"
		fi
	fi
}

function test_sparsefile {
echo -e "\n#====== test_sparsefile	============================="
	TESTNUM="$(( $TESTNUM + 1))"
	echo "test $TESTNUM totally sparse file"
	TESTFILE="$PREFIX/test${TESTNUM}"

	if testit
	then
		truncate -s 10M "$TESTFILE"
	else
		RSIZE="$( du  "$TESTFILE"		   | awk '{print $1}' )"
		ASIZE="$( du  --apparent-size "$TESTFILE"| awk '{print $1}' )"

		if [[ "$RSIZE" -eq "0"  ]]
		then
		        echo "OK file is sparse $RSIZE $ASIZE"
		else
		        echo "KO file is not sparse $RSIZE $ASIZE"
		fi
	fi

	#==========================================
	TESTNUM="$(( $TESTNUM + 1))"
	echo "test $TESTNUM partially sparse file "
	TESTFILE="$PREFIX/test${TESTNUM}"

	if testit
	then
		#64 char
		PATER="ABCDEFGHIJKLMNOPabcdefghijklmnop1234567812345678/*-+!:;,()[]_@=&"
		LOOP="10000"

		ITER=0
		while [[ "$ITER" -lt "$LOOP" ]]
		do
			ITER=$(( $ITER + 1 )) 
			echo "$PATER" >> "$TESTFILE"
		done
		echo "not sparse part"

		dd if=/dev/zero "of=$TESTFILE" bs=1 count=0 seek=1M > /dev/null 2> /dev/null
		echo "sparse part"

                ITER=0
		while [[ "$ITER" -lt "$LOOP" ]]
		do
			ITER=$(( $ITER + 1 ))
			echo "$PATER" >> "$TESTFILE"
		done
                echo "not sparse part"

		dd if=/dev/zero "of=$TESTFILE" bs=1 count=0 seek=2M > /dev/null 2> /dev/null
                echo "sparse part"

                ITER=0
		while [[ "$ITER" -lt "$LOOP" ]]
		do
			ITER=$(( $ITER + 1 ))
		       echo "$PATER" >> "$TESTFILE"
		done
		echo "not sparse part"
	else
		RSIZE="$( du  "$TESTFILE"                  | awk '{print $1}' )"
		ASIZE="$( du  --apparent-size "$TESTFILE"| awk '{print $1}' )"

		if [[ "$RSIZE" -ne "$ASIZE"  ]]
		then
		        echo "OK file is partially sparse $RSIZE $ASIZE"
		else
		        echo "KO file is not sparse $RSIZE $ASIZE"
		fi
	fi
}

setup_testenv "$1"
test_users
test_permissions
test_chattrs
test_acl
test_dates
test_links
test_specialdevices
test_xattrs
test_filenames
test_bincopy
test_highvalues
test_onefileperuser
test_sparsefile
