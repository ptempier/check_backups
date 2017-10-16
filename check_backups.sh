#!/bin/bash
#set -x
PREFIX=/tmp/filetests/
mkdir -p "$PREFIX"

#======================================
function testit {
	if	[ "$MODE" = "READ" ]
	then
		return 1
	elif 	[ "$MODE" = "WRITE" ]
	then
		return 0
	fi
}
#======================================
echo -e "\nsetting up env"

if [ -z "$1" ]
then
	echo "please specify READ or WRITE"
	exit 1
elif [ "$1" = "READ" ]
then
	echo "=========WRITE MODE"
elif [ "$1" = "WRITE" ]
then
	echo "=========READ MODE"
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
TESTNUM="1"
TESTFILE="$PREFIX/test$TESTNUM"
REFID="50123"
echo -e "\ntest $TESTNUM : user doesn t exist locally"

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
	USR="$(ls -l "$TESTFILE" | awk '{print $3}')"
	if [[ "$USR" -ne "$REFID" ]]
	then
		echo "KO user id is different $USR != $REFID"
	else 
		echo "OK same grp id : $USR"
	fi

        GRP="$(ls -l "$TESTFILE" | awk '{print $4}')"
		if [[ "$GRP" -ne "$REFID" ]]
	then
		echo "KO group id is different $GRP != $REFID"
	else
		echo "OK same grp id : $GRP"
	fi
fi

#=======================================
TESTNUM="2"
echo -e "\ntest $TESTNUM random user"
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
        USRB="$(ls -l "$TESTFILE" | awk '{print $3}')"
        if [ "$USR" != "$USRB" ]
        then
                echo "KO user id is different $USR != $USRB"
        else 
                echo "OK same grp id $USR"
        fi

        GRPB="$(ls -l "$TESTFILE" | awk '{print $4}')"
                if [ "$GRP" != "$GRPB" ]
        then
                echo "KO group id is different $GRP != $GRPB"
        else
                echo "OK same grp id : $GRP"
        fi
fi

#=======================================
TESTNUM="3"
echo -e "\ntest $TESTNUM acl"
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
TESTNUM="4"
echo -e "\ntest $TESTNUM mtime"
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
TESTNUM="5"
echo -e "\ntest $TESTNUM  permissions"
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
TESTNUM="6"
echo -e "\ntest $TESTNUM permissions"
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
TESTNUM="7"
echo -e "\ntest $TESTNUM hardlink"
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
TESTNUM="8"
echo -e "\ntest $TESTNUM symlink"
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
TESTNUM="9"
echo -e "\ntest $TESTNUM atime"
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
TESTNUM="10"
echo -e "\ntest $TESTNUM character device"
TESTFILE="$PREFIX/test$TESTNUM"
MAJ="3"
MIN="2"
TYPE="c"
if testit
then
	mknod "$TESTFILE" "$TYPE" "$MAJ" "$MIN"
else
        TYPEB="$(ls -l "$TESTFILE"| cut -c 1)"
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
TESTNUM="11"
echo -e "\ntest $TESTNUM xattrs"
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

