#!/bin/bash
#set -x
PREFIX=/tmp/filetests/
mkdir -p "$PREFIX"
TESTNUM="0"
cd "$PREFIX"
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
#======================================
echo -e "\nsetting up env"

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
        rm -rf "$PREFIX"
        exit 0
elif    [ "$1" = "BACKUP" ]
then
        echo "backuping $PREFIX"
	urbackupclientctl  start -i
        exit 0

elif    [ "$1" = "RESTORE" ]
then
	echo "restoring $PREFIX"
	urbackupclientctl restore-start -b last -d filetests
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

#=======================================
TESTNUM="$(( $TESTNUM + 1))"
TESTFILE="$PREFIX/test$TESTNUM"
REFID="50123"
echo -e "\ntest $TESTNUM :file,  user doesn t exist locally"

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
echo -e "\ntest $TESTNUM : folder user don t exist locally"

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
echo -e "\ntest $TESTNUM file,  10th  user, 11th group"
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
echo -e "\ntest $TESTNUM file,  last passwd user id"
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
echo -e "\ntest $TESTNUM folder, random user"
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
echo -e "\ntest $TESTNUM folder, last passwd user id"
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




#=======================================
TESTNUM="$(( $TESTNUM + 1))"
echo -e "\ntest $TESTNUM file  acl"
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
echo -e "\ntest $TESTNUM folder acl"
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


#=======================================
TESTNUM="$(( $TESTNUM + 1))"
echo -e "\ntest $TESTNUM file mtime"
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
echo -e "\ntest $TESTNUM folder mtime"
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
echo -e "\ntest $TESTNUM  file permissions"
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
echo -e "\ntest $TESTNUM  folder permissions"
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
echo -e "\ntest $TESTNUM file  permissions"
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
echo -e "\ntest $TESTNUM folder  permissions"
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
echo -e "\ntest $TESTNUM file hardlink"
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
                echo "KO $HLINK hrdlink != 3"
        fi
fi

#=======================================
TESTNUM="$(( $TESTNUM + 1))"
echo -e "\ntest $TESTNUM file symlink"
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
echo -e "\ntest $TESTNUM folder symlink"
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
echo -e "\ntest $TESTNUM file atime"
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
echo -e "\ntest $TESTNUM folder atime"
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


#=======================================
TESTNUM="$(( $TESTNUM + 1))"
echo -e "\ntest $TESTNUM character device"
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
echo -e "\ntest $TESTNUM file  xattrs"
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
echo -e "\ntest $TESTNUM folder xattrs"
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
#=======================================
TESTNUM="$(( $TESTNUM + 1))"
echo -e "\ntest $TESTNUM file special filename"
SPEC="$(printf "\xc3\xa9\xc3\xa8\xc3\xa7\xc3\xa0\xc3\xb9\xc3\xb9\x3d\x2b\x2d\xc3\xa7\x2d\x28\x29\x36\x31\x61\x7a\x65\xc2\xa8\xc2\xa3\xe2\x82\xac\x23\x2c\x78\x20\x61\x7a\x7e")"
TESTFILE="$PREFIX/test${TESTNUM}_${SPEC}"

if testit
then
        > "$TESTFILE"
else
        if [ -e  "$TESTFILE" ]
        then
                echo "OK file exists $TESTFILE"
        else
                echo "KO file absent $TESTFILE"
        fi
fi
#=======================================
TESTNUM="$(( $TESTNUM + 1))"
echo -e "\ntest $TESTNUM folder special filename"
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


#=======================================
TESTNUM="$(( $TESTNUM + 1))"
echo -e "\ntest $TESTNUM sparse file"
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

#=======================================
TESTNUM="$(( $TESTNUM + 1))"
echo -e "\ntest $TESTNUM invalid looped symlink"
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
echo -e "\ntest $TESTNUM folder symlink loop"
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
