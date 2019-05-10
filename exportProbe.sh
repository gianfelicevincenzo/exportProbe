#!/bin/bash
set -o noclobber

NAME_MAC_FILE_VENDOR="oui.txt"

TABLE='probeSniffer'
DB=""
COLUMN=0
SSID=0
NULL_SSID=0
SSID_AND_MAC_CORRECT=0
NULL_MAC_VENDOR=0
REMOVE_BROADCAST=0
FORCE_OPERATION=0
PRINT_RAW_DB=0
REPLACE_MAC_VENDOR_ERROR=0
REMOVE_DUPLICATE=0
SORT=0
VENDOR_RESOLVE=""
CONTENT_DB=""

function help() {
cat << "EOF"
                            _   ____            _          
  _____  ___ __   ___  _ __| |_|  _ \ _ __ ___ | |__   ___ 
 / _ \ \/ / '_ \ / _ \| '__| __| |_) | '__/ _ \| '_ \ / _ \
|  __/>  <| |_) | (_) | |  | |_|  __/| | | (_) | |_) |  __/
 \___/_/\_\ .__/ \___/|_|   \__|_|   |_|  \___/|_.__/ \___|
          |_|

EOF
	echo""
	echo " Usage: $0 -d file.db [ -r | -e | -n ] | -h"
	echo ""
	echo " Options:"
	echo " 	-d <file>	Database file"
	echo "	-f		Force read DB in case of error"
	echo "	-r		Print raw DB"
	echo " 	-e		Print only devices with an SSID"
	echo " 	-n	        Print only devices that have null SSID field"
	echo "	-M		Print only devices that do not have a MAC vendor"
	echo " 	-E	        Print only devices that have correct SSID and MAC vendor field"
	echo "	-B		Print without broadcast devices"
	echo "	-D		Remove duplicate lines"
	echo "	-S		Sort for ESSID"
	echo " 	-h		Show this help"
	echo " 	-m		Search Vendor MAC Address for devices that were not found"
	echo "			The file default is 'oui.txt'"
	echo ""
}

function export_db_sqlite() {
	#CONTENT_DB="$(sqlite3 -csv "$DB" "select * from "$TABLE";")" # Output CSV
	CONTENT_DB="$(sqlite3 "$DB" "select * from "$TABLE";")"
}

function check_db() {
	check_sqlite="$(file --mime-type -b "$DB")"
	if [[ $FORCE -eq 1 ]]; then
		return
	fi
	if ! echo "$check_sqlite" | grep -i 'sqlite' &> /dev/null;  then 
		echo "Errore: Il file '$DB' non e' un DB Sqlite"
		exit 1
	fi
}

function output_data() {
	if [[ $PRINT_RAW_DB -eq 1 ]]; then
		echo "$CONTENT_DB"
		exit 0
	fi

	if [[ $REMOVE_DUPLICATE -eq 1 ]]; then
		CONTENT_DB="$(echo "$CONTENT_DB" | sort -uk1,3)"
	fi
	if [[ $SSID -eq 1 ]]; then
		CONTENT_DB="$(echo "$CONTENT_DB" | grep -v '|SSID: |')"
	fi
	if [[ $NULL_SSID -eq 1 ]]; then
		CONTENT_DB="$(echo "$CONTENT_DB" | grep '|SSID: |')"
	fi
	if [[ $SORT -eq 1 ]]; then
		CONTENT_DB="$(echo "$CONTENT_DB" | sort -t '|' -k3,3)"
	fi
	if [[ $NULL_MAC_VENDOR -eq 1 ]]; then
		CONTENT_DB="$(echo "$CONTENT_DB" | grep 'RESOLVE-ERROR')"
	fi
	if [[ $SSID_AND_MAC_CORRECT -eq 1 ]]; then
		CONTENT_DB="$(echo "$CONTENT_DB" | grep -Ev '\|SSID: \||\|RESOLVE-ERROR\|')"
	fi
	if [[ $REMOVE_BROADCAST -eq 1 ]]; then
		CONTENT_DB="$(echo "$CONTENT_DB" | grep -iv 'ff:ff:ff:ff:ff:ff')"
	fi
	if [[ $REPLACE_MAC_VENDOR_ERROR -eq 1 ]]; then
		if [ ! -f oui.txt ]; then
			echo "Errore: Impossibile trovare il file 'oui.txt'"
			exit 1
		fi
		MAC_SEARCH=($(echo "$CONTENT_DB" | grep 'RESOLVE-ERROR' | awk 'BEGIN{FS="|"}{print $1}' | paste -s -d' '))
		if [ -z "$MAC_SEARCH" ]; then
			return
		fi
      VENDOR_FOUND=""
      LENGTH=${#MAC_SEARCH[@]}
				
		echo "+ Total MAC: $LENGTH"
		echo "+ Searching vendor..."
                
		for (( i=0; i<$LENGTH; i++ )); do
			VENDOR_FOUND="$(grep -Ei "$(echo ${MAC_SEARCH[$i]} | awk 'BEGIN{FS=":"}{print $1$2$3}')""|""$(echo ${MAC_SEARCH[$i]} | awk 'BEGIN{FS=":"}{print $1":"$2":"$3}')" $NAME_MAC_FILE_VENDOR | awk '{print $2}')"
			if [ ! -z "$VENDOR_FOUND" ]; then
				CONTENT_DB="$(echo "$CONTENT_DB" | sed s/${MAC_SEARCH[$i]}\|RESOLVE-ERROR\|/${MAC_SEARCH[$i]}\|$VENDOR_FOUND\|/)"
			fi
		done
	fi

	echo ""
	echo "$CONTENT_DB" | column -t -s'|'
}

##MAIN##
if [[ $# -lt 1 ]]; then
	help
	exit 1
fi

while getopts "d:DSBreEnMmhf" arg; do
	case "$arg" in
		h)
			help
			exit 0
			;;
		d) # Database input file
			DB="$OPTARG"

			if [ ! -f "$DB" ]; then
				echo "Errore: Il file '$DB' non esiste"
				exit 1
			fi
			;;
		r)
			PRINT_RAW_DB=1
			;;
		e)
			SSID=1
			;;
		E)
			SSID_AND_MAC_CORRECT=1
			;;
		B)
			REMOVE_BROADCAST=1
			;;
		n)
			NULL_SSID=1
			;;
		S)
			SORT=1
			;;
		M)
			NULL_MAC_VENDOR=1
			;;
		D)
			REMOVE_DUPLICATE=1
			;;
		f)
			FORCE=1
			;;
		m)
			REPLACE_MAC_VENDOR_ERROR=1
			;;
		*|?)
			exit 1
			;;
	esac
done
shift $((OPTIND-1))

if [ -z "$DB" ]; then
	echo "Errore: Nessun DB specificato"
	exit 1
fi

echo ""
check_db
echo "* Dump DB '"$DB"'..." >&2
export_db_sqlite
output_data
echo ""

exit 0

