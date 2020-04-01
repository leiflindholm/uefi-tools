#!/bin/bash

if [ ! -d $HOME/tmp ]; then
    mkdir $HOME/tmp || echo "Coluldn't create ~/tmp!" >&1 && exit 1
    chmod 700 $HOME/tmp
fi

if [ ! -d $HOME/incoming ]; then
    mkdir $HOME/incoming || echo "Coluldn't create ~/tmp!" >&1 && exit 1
    chmod 700 $HOME/incoming
fi    

sanitise_subject()
{
    STRING=`echo "$SUBJECT" | tr "'" "."`
    SED_STR='{ s@\[@@g; s@\]@@g; s@[*()" \t]@_@g; s@[/:]@-@g; s@^ \+@@; s@\.\.@.@g; s@-_@_@g; s@__@_@g; s@\.$@@; }'
    STRING=`echo $STRING | sed -e "$SED_STR"`
    echo "$STRING"
}

has_recipient()
{
    cat $PATCH_FILE | formail -c -x"To:" | grep -i "$1" >/dev/null
    [ $? -eq 0 ] && return 0
    cat $PATCH_FILE | formail -c -x"Cc:" | grep -i "$1" >/dev/null
    [ $? -eq 0 ] && return 0

    return 1
}

EDK2LIST=devel@edk2.groups.io

CRLF=false

PATCH_FILE=`mktemp --tmpdir="$HOME/tmp"  mutt-patch.XXXXXX`
cat > $PATCH_FILE
SUBJECT=`cat $PATCH_FILE | formail -c -xSubject:`

if has_recipient "$EDK2LIST"; then
    CRLF=true
fi

FILENAME=`sanitise_subject "$SUBJECT"`

if [ $CRLF == true ]; then
    edk2-to-git-am.sh "$PATCH_FILE" > /dev/null 2>&1 \
	|| echo "Failed to do CRLF conversion, edk2-to-git-am.sh missing?" >&2
fi
mv "$PATCH_FILE" "$HOME/incoming/$FILENAME" || rm "$PATCH_FILE"
