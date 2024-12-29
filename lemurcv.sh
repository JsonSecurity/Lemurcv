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
cent=$C
bord=$N
excr=$W
eye="\e[38;2;173;255;47m"
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

IN_IMG="isolve"
OUT_IMG="images"

banner() {
	echo -e """
                                                        
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

process=false

help() {
	echo -e "\n [!] Usage:
	
 $0 -l		# loop mode
 $0 -d <path> 	# dir images *
 $0 -g <text>	# promt gemini
 $0 -t <text>	# promt tauro *"
}

verify() {
	IN_IMG=$DIR

	if [[ ! -d try ]];then
	    mkdir try
	fi

	if [[ ! -n $PROMT_TAURO ]];then
        echo -e "\n$A -pt <promt>"
        exit 1
    fi
	
	if [[ ! -d $IN_IMG ]];then
	    echo -e "$E Dir not found\n"
	    exit 1
	else
	    LEN_AFTER=$(ls $IN_IMG | wc -l)
	    echo -e "$T Dir:$info $IN_IMG/"
	    echo -e "$T Len:$info $LEN_AFTER\n"
	    echo -e "$info Waiting for images..."
	fi
}

lemurcv() {
	file=$(ls -t $IN_IMG | head -n "-${LEN_AFTER}")
	#echo -e "file: $file"
	process=false
	if [[ -f "$IN_IMG/$file" ]];then
		echo -e "\n$S Image:$info $file"

		echo -e "\n$T TAURO"
		#tauro=$(bash tauro-ai.sh -p "Extrae todo el texto de la imagen, tambien la pregunta en ingles, extraelas en orden para luego resolverlos" -i "$IN_IMG/$file" -s)
		#tauro=$(bash tauro-ai.sh -p "Extrae todo el texto de la imagen, tambien la pregunta, extraelas en orden para luego resolverlos" -i "$IN_IMG/$file" -s)

		#echo "$IN_IMG/$file"
		img="$IN_IMG/$file"
		echo $img > img.txt

		bash -c "./tauro-ai.sh -p \"$PROMT_TAURO\" -i $img -s"
		#echo $cmd
		#bash -c $cmd

		#if [[ -n $PROMT_GEMINI ]];then
		echo -e "\n$T GEMINI"
		process=true
		bash gemini.sh "\"$PROMT_GEMINI: $tauro\""
		#fi
		
		echo -e "\n$info Waiting for images..."
	fi
}

if [[ ! $1 ]];then
	help
	exit 1
fi
while getopts h,l,d:,g,t: arg;do
	case $arg in
		h) help;;
		l) LOOP=true;;
		d) DIR=$OPTARG;;
		g) PROMT_GEMINI=$OPTARG;;
		t) PROMT_TAURO=$OPTARG;;
		*) help;;
	esac
done

banner
verify

if [[ $LOOP ]];then
	while true;do
		lemurcv
		sleep 2

		if [[ -f "$IN_IMG/$file" ]];then
			mv "$IN_IMG/$file" try
			#echo "del"
		fi
	done
else
	lemurcv
fi
