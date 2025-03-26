#!/bin/bash

APIKEY=$(cat ".APIKEY" 2>/dev/null)

if [[ ! -n $APIKEY ]];then
	echo -e "\n[!] .APIKEY not found\n"
	exit 1
fi

if [[ ! $1 ]];then
	echo -e "\n[!] Promt error\n"
	exit 1
fi

curl -sN https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$APIKEY \
 -H 'Content-Type: application/json' \
 -d    "{
            \"contents\":
            {
                \"role\": \"user\",
                \"parts\":
                    {
                \"text\": \"$1\"
                }
            },
        }" -o data/request.txt

c="33"
b="e[${c}m"

ver=$(cat data/request.txt | awk -F"\"text\":" '{print $2}' | tr -d '\n' \
	        | sed 's/^ *"//; s/" *$//' \
	        | sed 's!\*\*!\\'"$b"'!g' \
	        | sed 's!'"$c"'m\\n!0m\\n!g' \
	        | sed 's!'"$c"'m !0m !g' \
	        | sed 's!\\n\*!\\n -!g' \
	        | sed 's!\\"!"!g')

echo -e $ver
