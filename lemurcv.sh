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

#mas
bol="${W}\033[1m"
cur="\033[3m"
sub="\033[4m"

#salidas/entradas
bord=$N
excr=$W
eye="\e[38;2;173;255;47m"
cent=$eye
info=$eye
hed=$W

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
script="${bol}$bord [$W ${info}Lemurcv${bord} ]"

APIKEY=$(cat .APIKEY 2>/dev/null)

banner() {
    echo -e """$W

        .lo;.                              .'lo'
    ...',xNN0dc.                        .:oONWO:'....
   'codO0KNMMNk,                        .dXMMWK00xol,.
  .:okXWMMMWk,       ..,:c:'.,c:;'.       'dXMMMWXOdc.
  .:d0WMMMWd.      ,d0XWMMW0kXMMWNKxc.      cNMMMWKkl'
  .;xXMMMMK,       ;lokXWMMMMMMMNOdlc.      .OMMMMNOc.
  .:kXWWWMX;      ${eye}.cl:''${hed}dNMMMMWO${eye};.;lc,${hed}      '0MMWWNOl'.
  .,:cokOKK;     ${eye}'0NKNO..${hed}kMMMMX${eye};.dNKXX:${hed}     .OX0Odl:;..
      ..;Ox.     ${eye}.dKKKo.'${hed}0MMMMN${eye}c.cKKKO,${hed}      o0c...
       .lx,       ${eye} .,..,${hed}OWMMMMMX${eye}l..,'.${hed}       .xx.
       :Kk.          .dNW0kOOkOXWO,           dNo.
       ,OK,         .xWMXo,..':OMMK,         .kK:.
       .xWk.        .xWMWWXkd0WWMMK;        .dN0,
        'col.        .o0NNXKKXNNKx,        .cdl;.
                       .';cccc:,.
                           ...


             $autor $script
"""
}

help() {
    echo -e "
[!] Usage:

 $0 -p <text>     # promt opticai *
 $0 -g <text>     # promt gemini

 $0 -d <path>     # dir images *
 $0 -l            # loop mode
 "
}

verify() {
	if [[ ! -n $APIKEY ]];then
		echo -e "\n$E .APIKEY not found\n"
		exit 1
	fi

	if [[ ! -n $(command -v jq) ]];then
		echo -e "\n$A Installing jq...\n"
		pkg install jq -y > /dev/null
	fi

	#if [[ ! -n $G_PROMT ]];then
	#	echo -e "\n$E -g <promt>\n"
	#	exit 1
	#fi

	if [[ ! -n $O_PROMT ]];then
		echo -e "\n$E -o <promt>\n"
		exit 1
	fi

	if [[ ! -d $DIR_IMAGE ]];then
		echo -e "\n$E -d path not found\n"
		exit 1
	else
		LEN_DIR=$(ls $DIR_IMAGE | wc -l)
		echo -e "$T Dir:$eye $DIR_IMAGE"
		echo -e "$T Len:$eye $LEN_DIR"
		echo -e "\n${eye} Waiting for images...\n"
	fi

	if [[ ! -d worker ]];then
		mkdir worker
	fi
}
lemurcv() {
	IMG_FILE=$(ls -t $DIR_IMAGE | head -n "-${LEN_DIR}")
	PATH_IMG="${DIR_IMAGE}/${IMG_FILE}"
	if [[ -f $PATH_IMG ]];then
		echo -e "$T Image:$eye $IMG_FILE"

		echo -e "\n$T OpticAI...\n"
		opticai=$(bash -c "./opticai.sh -p \"$O_PROMT\" -i \"$PATH_IMG\" -s")
		echo -e $opticai

		if [[ -n $G_PROMT ]];then
			echo -e "\n$T Gemini...\n"
			bash -c "./gemini.sh \"$G_PROMT: $opticai\""
		fi
	fi
}

if [[ ! $1 ]];then
	help
	exit 1
fi
while getopts h,l,d:,g:,p: arg;do
	case $arg in
		h) help;;
		l) LOOP_MODE=true;;
		d) DIR_IMAGE=$OPTARG;;
		g) G_PROMT=$OPTARG;;
		p) O_PROMT=$OPTARG;;
	esac
done

banner
verify
while true;do
	lemurcv

	if [[ -f $PATH_IMG ]];then
		mv $PATH_IMG worker
		if [[ ! $LOOP_MODE ]];then
			exit 0
		else
			echo -e "\n${eye}Waiting for images...\n"
		fi
	fi
	sleep 2
done
