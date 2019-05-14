#  This file is a part of tool exportProbe
#
#  Coded by: vincenzogianfelice <developer.vincenzog@gmail.com>
#  View my github at https://github.com/vincenzogianfelice

BEGIN {
	FS="|"
	printf("[\n")
}
{       
        #Header DB
	if ( NR == 1 ) {
	   if ( NF > 6 ) {
	   	exit 1
	   }
	   #Assign variable header DB
	   mac=$1
	   vendor=$2
	   essid=$3
	   date=$4
	   signal=$5
	   mac_associate=$6

	} else {
	   #Write parser data DB
	   printf("   {\n")
           #printf("      id : \"%d\",\n", NR)
	   printf("      \"%s\" : \"%s\",\n", mac, $1)
	   printf("      \"%s\" : \"%s\",\n", vendor, $2)
	   printf("      \"%s\" : \"%s\",\n", essid, $3)
	   printf("      \"%s\" : \"%s\",\n", date, $4)
	   printf("      \"%s\" : \"%s\",\n", signal, $5)
	   printf("      \"%s\" : \"%s\",\n", mac_associate, $6)
	   printf("   },\n")
        }
}
END {
	printf("]\n")
}
