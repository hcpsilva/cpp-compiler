#!/usr/bin/bash

set -x

FILE="$1"

if [ -n "$(grep 'parser.tab.h' $FILE)" ]; then
    sed -i 's/parser.tab.h/evil-include.hh/' $FILE
else
    STDIO_LINE=$(grep -n 'stdio' $FILE | cut -d ' ' -f1)

    if [ -z $STDIO_LINE ]; then
        STDIO_LINE=1
    fi

    sed -i "$STDIO_LINE a#include \"evil-include.hh\"" $FILE
fi
