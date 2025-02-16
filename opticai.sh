#!/bin/bash

#colores
W="\e[0m"
N="\e[38;2;100;102;109m"
n="\e[30m"
R="\e[38;2;255;0;0m"
G="\e[38;2;19;255;0m"
Y="\e[33m"
B="\e[34m"
P="\e[35m"
C="\e[36m"
L="\e[37;2m"

#resaltado
rW="\e[48m"
rN="\e[40;1m"
rG="\e[42m"
rY="\e[43m"
rB="\e[44m"
rP="\e[45m"
rC="\e[46m"
rL="\e[47m"

bol="${W}\033[1m"
cur="\033[3m"
sub="\033[4m"

cent=$R
bord=$N
excr=$W
info=$cent

T="$bord [${cent}+${W}${bord}]$excr"
F="$bord [${cent}-${W}${bord}]$excr"

A="${W}$bord [${bol}${Y}!${W}${bord}]$excr"
E="${W}$bord [${bol}${R}✘${W}${bord}]$excr"
S="${W}$bord [${bol}${G}✓${W}${bord}]$excr"

I="$bord [${cent}\$${bord}]${cent}❯$excr"
U="$bord [${cent}${bord}]${cent}❯$excr"

YN="$bord[${cent}Y${bord}/${cent}N${bord}]${excr}"

#info
autor="${bol}$bord [$W ${info}Json Security${bord} ]"
script="${bol}$bord [$W ${info}OpticSHK${bord} ]"


# Variables globales
IMG_PATH_2=""
BASEURL="https://generativelanguage.googleapis.com"
APIKEY=$(cat .APIKEY 2>/dev/null)

tmp_header_file=upload-header.tmp

if [[ ! -n $APIKEY ]];then
	echo -e "\n$A .APIKEY not found"
	exit 1
fi

banner() {
	echo -e """$W
               ..                                  
               ,;                                  
               ;c.                                 
               lk,                                 
 .,         ,dKWKxc'                              
 .l'      ,xNMMMMMWXx;.                           
 .do..;:ckNMMMMMMMMMMNd.                          
  oXOKWWMMMMMMMMMMMMMMNl                          
 .o0kKNWMMMMMMMMMMMMMMMx.                         
 .o:..,oXMMMMMMMMMMMMMMx.                         
 .,.   cXMMMMMMMMMMMMMWk.                         
     .:dkxdONMMMMMMMMN00XO:.                       
  .,cloc,.   'lxO00Odc'..;lddo;.                    
.';;'.           ..         .,cc:'                  
                                ..
 $autor $script$W\n"""
}

help() {
	echo -e """\n [+] Usage: 

 $0 -p <promt>	# promt
 $0 -n <name.jpg> 	# name save image
 $0 -i <image>	# path image
 $0 -d <url>		# download image
 $0 -s 		# silent mode"""
}

verify() {
	if [[ ! -n $(command -v jq) ]];then
		echo -e "\n$A Inatalling jq"
		apt-get install jq -y
		sleep .1
		banner
	fi

	if [[ ! -d data ]];then
		mkdir data
	fi
}

uploadFile() {
	curl "${BASEURL}/upload/v1beta/files?key=${APIKEY}" \
	  -D upload-header.tmp \
	  -H "X-Goog-Upload-Protocol: resumable" \
	  -H "X-Goog-Upload-Command: start" \
	  -H "X-Goog-Upload-Header-Content-Length: ${NUM_BYTES}" \
	  -H "X-Goog-Upload-Header-Content-Type: ${MIME_TYPE}" \
	  -H "Content-Type: application/json" \
	  -d "{'file': {'display_name': '${DISPLAY_NAME}'}}" 2> /dev/null
	
	upload_url=$(grep -i "x-goog-upload-url: " "${tmp_header_file}" | cut -d" " -f2 | tr -d "\r")
	rm "${tmp_header_file}"

	#echo $upload_url
	#echo -e "\n\n $MIME_TYPE\n\n"
}

fileUploads() {
	
	curl "${upload_url}" \
	  -H "Content-Length: ${NUM_BYTES}" \
	  -H "X-Goog-Upload-Offset: 0" \
	  -H "X-Goog-Upload-Command: upload, finalize" \
	  --data-binary "@${IMG_PATH_2}" 2> /dev/null > data/file_info.json
	
	file_uri=$(jq ".file.uri" data/file_info.json)
	#echo $file_uri
}

response() {
	json_data=$(printf '{
	  "contents": [{
	    "parts": [
	      {"text": "%s"},
	      {"file_data": {
	        "mime_type": "%s",
	        "file_uri": %s
	      }}
	    ]
	  }]
	}' "$PROMT" "$MIME_TYPE" "$file_uri")

	#echo $json_data | jq
	
	curl "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$APIKEY" \
	    -H "Content-Type: application/json" \
	    -X POST \
	    -d "$json_data" > data/response.json 2> /dev/null

	c="33"
	b="e[${c}m"

	if [[ $SILENT ]];then
		text_response=$(jq ".candidates[].content.parts[].text" data/response.json \
			| sed 's!\\n! !g' | sed 's!*!!g' \
			| sed 's!"!!g' | sed 's!\\!!g' \
			| tr -d '`')
	else
		text_response=$(jq ".candidates[].content.parts[].text" data/response.json \
	        | sed 's/^ *"//; s/" *$//' \
	        | sed 's!\*\*!\\'"$b"'!g' \
	        | sed 's!'"$c"'m\\n!0m\\n!g' \
	        | sed 's!'"$c"'m !0m !g' \
	        | sed 's!\\n\*!\\n -!g' \
	        | sed 's!\\"!"!g')
	fi
	echo -e "\n\n$text_response" >> data/history.txt
	echo -e $text_response
}

downloadImage() {
	extension=".jpg"

	if [[ ! -n $URL_IMG ]];then
		echo -e "\n URL not found -d <url>"
		help
		exit 1
	fi
	
	if [[ ! -n $NAME_IMG ]];then
		NAME_IMG=$(($RANDOM % 1000000))
		NAME_IMG="$NAME_IMG.jpg"
	fi

	if [[ ! -d images ]];then
		mkdir images
	fi

	wget $URL_IMG -O $NAME_IMG &>/dev/null
	if [[ $(echo $?) == 0 ]];then
		mv $NAME_IMG images/
		IMG_PATH_2="images/$NAME_IMG"
		echo -e "\n$T Download success$G $IMG_PATH_2"
	else
		echo -e "\n$E Download error"
		exit 1
	fi
}

verifyOptions() {
	if [[ ! -f $IMG_PATH_2 ]];then
		echo -e "\n$E Image path not found"
		exit 1
	fi

	sleep 1
	
	if [[ ! -n $PROMT ]];then
		echo -e "\n$E promt.txt not found"
		exit 1
	fi

	MIME_TYPE=$(file -b --mime-type "${IMG_PATH_2}")
	NUM_BYTES=$(wc -c < "${IMG_PATH_2}")
	DISPLAY_NAME=TEXT
}

opticshk() {
	verifyOptions

	banner

	echo -e "$T Upload file"
	uploadFile

	echo -e "$S Upload success"

	fileUploads

	echo -e "\n$T Analyzing...\n"
	response
}

silentTauroIA() {
	verifyOptions
	uploadFile
	fileUploads
	response
}

verify

if [[ ! $1 ]];then
	help
	exit 1
fi
while getopts h,i:,d:,p:,n:,s arg;do
	case $arg in
		h) help;;
		i) IMG_PATH_2=$OPTARG;;
		p) PROMT=$OPTARG;;
		n) NAME_IMG=$OPTARG;;
		d) URL_IMG=$OPTARG;downloadImage;;
		s) SILENT=true;;
		*) help;;
	esac
done
if [[ $SILENT ]];then
	silentTauroIA
else
	opticshk
fi
