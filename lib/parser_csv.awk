#  This file is a part of tool exportProbe
#
#  Coded by: vincenzogianfelice <developer.vincenzog@gmail.com>
#  View my github at https://github.com/vincenzogianfelice

BEGIN {
	FS="|"
}
{       
        #Header DB
	if ( NR == 1 ) {
	   if ( NF > 6 ) {
	   	exit 1
	   }
	   #Assign variable header DB
	   printf("%s,%s,%s,%s,%s,%s\n",$1,$2,$3,$4,$5,$6)

	} else {
	   #Write parser data DB
	   printf("%s,%s,\"%s\",\"%s\",%s,%s\n",$1,$2,$3,$4,$5,$6)
        }
}
