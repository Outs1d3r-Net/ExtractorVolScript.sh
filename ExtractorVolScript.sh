#!/bin/bash 

#VARIABLES
##########
fileExtr="$1"
path_dump="$(ls -la dumpfiles 2>&1 | grep cannot | wc -l)"
Volatility="$(which volatility)"


#REQUIREMENTS
#############
if [ -z "$Volatility" ];then
	clear
	echo -e "\n[*] OH NO !! volatility not found ! please install with: \n\tapt-get install volatility -y\n Command or visit the 'Releases' page in https://www.volatilityfoundation.org/ for install.\n"
	exit 0
fi


#FUNCTIONS
##########
function exTractF { #EXTRACT FILE FROM VMEM WITH OFFSET ADDRESS
	clear
	read -p 'Please, set the VMEMDump name: ' fMD
	clear
	echo 'Please wait, extracting file from offset= '$pgR'...'
	pMF="$($Volatility -f $fMD imageinfo 2>&1 | grep -i "profile" | cut -d ")" -f 2 | tail -n1 | cut -d " " -f 3 | tr -d ',')"
	volatility -f $fMD --profile=$pMF dumpfiles -Q $pgR -D dumpfiles/ -u -n -S summary.txt;
	echo -e "\nOffset '$pgR' extracted successful in dumpfiles folder!"
}

function usage { #SHOW THE BANNER
	clear
	echo -e "############################################\n#### ExtractorVolScript with volatility ####\n####\t\t\t\t\t####\n#### By: TheMasterOFTraps\t\t####\n############################################\n\nUsage: "$0" offset_Vfile_dump\n\nEx: "$0" 0x000000000ec0bf80";
	echo -e "\n\t --help for MORE options.\n"
	exit 0;	
}

function help { #MORE HELP OPTIONS
	clear
	echo -e "############################################\n#### ExtractorVolScript with volatility ####\n############################################\n\nMore Options:"
	echo -e "\t --search : For search a file in filescan archive.\n\t\t ?: For help in --search\n"
	echo -e "\t offset_Vfile_dump : For dump file offset from filescan archive.\n"
	echo -e "\t --clean : For delete files generate from "$0"\n"
}


#BANNER/USAGE
#############
if [ "$path_dump" != "0" ];then #CREATE THE DUMP PATH
	mkdir dumpfiles
fi

if [ "$1" == "" ];then
	usage

elif [ "$1" == "--help" ];then
	help

#MAIN
######
elif [ "$1" == "--search" ];then
	file_scan="$(ls -la filescan 2>&1 | grep cannot | wc -l)" #CHECKS IF THE FILESCAN ARCHIVE EXISTS
	if [ "$file_scan" != "0" ];then
		clear
		echo -e "\n[*] Error !! filescan not found, please set the command:\n\tvolatility -f VMEMDump --profile=PROFILE filescan >> filescan\n"
		read -p "Do you want to generate filescan ? y/n " gFS
		if [ "$gFS" == 'n' ];then
			clear
			echo "bye ! bye !"
			exit 0
		elif [ "$gFS" == 'y' ];then #CASE NO, GENERATE THE FILESCAN ARCHIVE
			read -p 'Please set the file VMemDump name: ' fMD
			clear
			echo "Please wait, extracting the filescan from $fMD..."
			pMF="$($Volatility -f $fMD imageinfo 2>&1 | grep -i "profile" | cut -d ")" -f 2 | tail -n1 | cut -d " " -f 3 | tr -d ',')" #GET THE FRIST PROFILE FROM fMD
			$($Volatility -f $fMD --profile=$pMF filescan >> filescan) #EXTRACT THE FILESCAN FROM pMF
			clear
			echo "filescan created !"
		else
			echo "Option not accepted !"
			exit 0
		fi
			
	else
		pgR=""
		while true;do #SEARCH FILES IN FILESCAN ARCHIVE
			read -p 'Search_file >>> ' pgR
			if [ "$pgR" == "clear" ];then
				clear
			elif [ "$pgR" == "?" ];then #OPTIONS INSIDE --SEARCH OPTION
				echo -e "\n\tCommands: \n\t---------\n\t[.dll/.txt/.doc/.etc...] For search file in filescan archive."
				echo -e "\t[0x00_Offset_address] For extract the file with offset address."
				echo -e "\t[clear] For clear screen."
				echo -e "\t[exit/quit/q] For exit program.\n"
			elif [ "$pgR" == "exit" ];then
				exit 0
			elif [ "$pgR" == "quit" ];then
				exit 0
			elif [ "$pgR" == 'q' ];then
				exit 0

			elif [[ $pgR == *"0x00"* ]];then #CALL EXTRACT FUNCTION FOR FILE WITH OFFSET ADDRESS FROM FILESCAN ARCHIVE
				exTractF
			else
				grep -i $pgR filescan | less
			fi
		done
	fi
	#exit 0
		
elif [[ $1 == *"0x00"* ]];then	#CALL EXTRACT FUNCTION FOR EXTRACT OFFSET FROM VMEMDump
	pgR=$1
	exTractF
	exit 0;

elif [ "$1" == '--clean' ];then
	clear
	rm -rf dumpfiles
	rm -rf filescan
	rm -rf summary.txt
	echo "Files have been deleted !"
	exit 0;

else
	clear
	echo 'Option not acceptd !'
	exit 0;
fi
