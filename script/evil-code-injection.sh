#!/usr/bin/bash

set -x

FILE="$1"

if [ -n "$(grep 'parser.tab.h' $FILE)" ]; then
    sed -i 's/parser.tab.h/evil-include.hh/' "$FILE"
else
    STDIO_LINE=$(grep -n 'stdio.h' "$FILE" | cut -d ' ' -f1)

    if [ -z $STDIO_LINE ]; then
        STDIO_LINE=1
    fi

    sed -i "${STDIO_LINE}s;^;#include \"evil-include.hh\"\n;" "$FILE"
fi

sed -i '/yylex_destroy/d' "$FILE"
