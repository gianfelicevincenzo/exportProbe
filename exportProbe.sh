#!/bin/bash
#
#  Coded by: vincenzogianfelice <developer.vincenzog@gmail.com>
#  View my github at https://github.com/vincenzogianfelice
#  My site: https://vincenzogianfelice.altervista.org

set -o noclobber

NAME_MAC_FILE_VENDOR="oui.txt"
count=0

TABLE='probeSniffer'
DB=""
COLUMN=0
SSID=0
NULL_SSID=0
MERGE_DB=()
BACKUP=0
SSID_AND_MAC_CORRECT=0
NULL_MAC_VENDOR=0
REMOVE_BROADCAST=0
FORCE_OPERATION=0
REPLACE_MAC_VENDOR_ERROR=0
REMOVE_DUPLICATE=0
SORT=0
VENDOR_RESOLVE=""
CONTENT_DB=""
EXPORT_RAW=0
EXPORT_CSV=0
EXPORT_HTML=0
EXPORT_JSON=0
EXPORT_SQLITE=0

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
	echo " Usage: $0 -d file.db [ -E | -e | -n | ... ] | -h"
	echo ""
	echo " Options:"
	echo " 	-d <file>   Database file"
	echo "	-f          Force read DB in case of error"
	echo " 	-e          Print only devices with an SSID"
	echo " 	-n          Print only devices that have null SSID field"
	echo "	-M          Print only devices that do not have a MAC vendor"
	echo " 	-E          Print only devices that have correct SSID and MAC vendor field"
	echo "	-B          Print without broadcast devices"
	echo "	-D          Remove duplicate lines"
	echo "	-s          Sort for ESSID"
	echo "	-u          Merge multiple DBs into principal DB"
	echo "	            (Es.) $0 -d file_principal.db -u file.db2 -u file.db3 -u file.db3 ecc..."
	echo "	-b	    Backup DB before merge with other DB"
	echo " 	-h          Show this help"
	echo " 	-m          Search Vendor MAC Address for devices that were not found"
	echo "	            The file default is 'oui.txt'"
	echo ""
	echo " Export Format:"
	echo "	-S	    Export Sqlite3 DB for backup"
	echo "	-R	    Export RAW Format"
	echo "	-C	    Export CSV format"
	echo " 	-H	    Export HTML format"
	echo "	-J	    Export JSON format"
	echo ""
}

function check_db() {
	check_sqlite="$(file --mime-type -b "$DB")"
	if [[ $FORCE -eq 1 ]]; then
		return
	fi
	if ! echo "$check_sqlite" | grep -i 'sqlite' &> /dev/null;  then
		echo "Errore: Il file '$DB' non e' un DB Sqlite" >&2
		exit 1
	fi
}

function export_db_sqlite() {
	CONTENT_DB="$(sqlite3 "$DB" "select * from "$TABLE";")"
}

function export_raw() {
	CONTENT_DB="$(sqlite3 -header "$DB" "select * from "$TABLE";")" # Output RAW 
	echo "$CONTENT_DB"
}

function export_csv() {
	CONTENT_DB="$(sqlite3 -header -csv "$DB" "select * from "$TABLE";")" # Output CSV
	echo "$CONTENT_DB"
}

function export_html() {
	CONTENT_DB="$(sqlite3 -header "$DB" "select * from "$TABLE";")" # Output RAW 
        echo "$CONTENT_DB" | awk -f lib/parser_html.awk
}

function export_json() {
	CONTENT_DB="$(sqlite3 -header "$DB" "select * from "$TABLE";")" # Output RAW 
	echo "$CONTENT_DB" | awk -f lib/parser_json.awk
}

function export_sqlite() {
	CONTENT_DB="$(sqlite3 "$DB" ".dump")"
	echo "$CONTENT_DB"
}
 
function output_data() {
	###EXPORT###
	if [[ $EXPORT_RAW -eq 1 ]]; then
		export_raw
		exit 0
	fi
	if [[ $EXPORT_CSV -eq 1 ]]; then
		export_csv
		exit 0
	fi
	if [[ $EXPORT_HTML -eq 1 ]]; then
		export_html
		exit 0
	fi
	if [[ $EXPORT_JSON -eq 1 ]]; then
		export_json
		exit 0
	fi
	if [[ $EXPORT_SQLITE -eq 1 ]]; then
		export_sqlite
		exit 0
	fi

	export_db_sqlite

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
			echo "Errore: Impossibile trovare il file 'oui.txt'" >&2
			exit 1
		fi
		MAC_SEARCH=($(echo "$CONTENT_DB" | grep 'RESOLVE-ERROR' | awk 'BEGIN{FS="|"}{print $1}' | paste -s -d' '))
		if [ -z "$MAC_SEARCH" ]; then
			return
		fi
		VENDOR_FOUND=""
		LENGTH=${#MAC_SEARCH[@]}

		echo "+ Total MAC: $LENGTH" >&2
		echo "+ Searching vendor..." >&2

		for (( i=0; i<$LENGTH; i++ )); do
			VENDOR_FOUND="$(grep -Ei "$(echo ${MAC_SEARCH[$i]} | awk 'BEGIN{FS=":"}{print $1$2$3}')""|""$(echo ${MAC_SEARCH[$i]} | awk 'BEGIN{FS=":"}{print $1":"$2":"$3}')" $NAME_MAC_FILE_VENDOR | awk '{print $2}')"
			if [ ! -z "$VENDOR_FOUND" ]; then
				CONTENT_DB="$(echo "$CONTENT_DB" | sed s/${MAC_SEARCH[$i]}\|RESOLVE-ERROR\|/${MAC_SEARCH[$i]}\|$VENDOR_FOUND\|/)"
			fi
		done
	fi

	echo "$CONTENT_DB" | column -t -s'|'
}

##MAIN##
if [[ $# -lt 1 ]]; then
	help
	exit 1
fi

while getopts "d:u:bDsBeEnMmhfSRCHJ" arg; do
	case "$arg" in
		h)
			help
			exit 0
			;;
		d) # Database input file
			DB="$OPTARG"

			if [ ! -f "$DB" ]; then
				echo "Errore: Il file '$DB' non esiste" >&2
				exit 1
			fi
			;;
		b)
			BACKUP=1
			;;
		u) # Merge DB
			if [ ! -f "$OPTARG" ]; then
				echo "Errore: Il DB '$OPTARG' non esiste" >&2
				exit 1
			fi
			count=$((count+1))
			MERGE_DB[$count]="$OPTARG"
			;;
		S)
			EXPORT_SQLITE=1
			;;
		R)
			EXPORT_RAW=1
			;;
		C)
			EXPORT_CSV=1
			;;
		H)
			EXPORT_HTML=1
			;;
		J)
			EXPORT_JSON=1
			;;
		e)
			SSID=1
			;;
		E) # Print only correct SSID and MAC Vendor field
			SSID_AND_MAC_CORRECT=1
			;;
		B) # Not print devices broadcast
			REMOVE_BROADCAST=1
			;;
		n)
			NULL_SSID=1
			;;
		s)
			SORT=1
			;;
		M) # Print only NULL MAC Vendor field
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
	echo "Errore: Nessun DB specificato" >&2
	exit 1
fi
if [[ "${MERGE_DB[@]}" ]]; then
	echo ""
	if [[ $BACKUP -eq 1 ]]; then
		if [ ! -f "${DB}_backup" ]; then
			echo "* Backup db $DB in ${DB}_backup" >&2
			echo "" >&2

			if ! cp "$DB" "${DB}_backup" &>/dev/null; then
				echo "Errore: Impossibile eseguire il backup DB. Probabile che non si hanno i permessi di scrittura." >&2
				exit 1
			fi
		else
			echo "Errore: un backup esiste gia" >&2
			exit 1
		fi
	fi

	for db_merge in $(seq 1 $count); do

		if sqlite3 "$DB" ".tables" | grep 'probeSniffer' &>/dev/null; then
			echo "Merging file '${MERGE_DB[$db_merge]}' in '$DB'..." >&2
			sqlite3 "${MERGE_DB[$db_merge]}" ".dump $TABLE" | grep ^INSERT | sqlite3 "$DB"
		else
			echo "Il file '${MERGE_DB[$db_merge]}' non e' un DB adatto o non e' un DB di probeSniffer" >&2
		fi
	done
	echo ""

	exit 0
fi

echo "" >&2
check_db
echo "* Dump DB '"$DB"'..." >&2
echo "" >&2
output_data

exit 0

