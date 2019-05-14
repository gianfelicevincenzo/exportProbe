#  This file is a part of tool exportProbe
#
#  Coded by: vincenzogianfelice <developer.vincenzog@gmail.com>
#  View my github at https://github.com/vincenzogianfelice

BEGIN {
   FS="|"
   printf("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n")
   printf("   <probe>\n")
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
      printf("      <devices id=\"%d\">\n",NR)
      printf("         <%s>%s</%s>\n", mac,$1,mac)
      printf("         <%s>%s</%s>\n", vendor,$2,vendor)
      printf("         <%s>%s</%s>\n", essid,$3,essid)
      printf("         <%s>%s</%s>\n", date,$4,date)
      printf("         <%s>%s</%s>\n", signal,$5,signal)
      printf("         <%s>%s</%s>\n", mac_associate,$6,mac_associate)
      printf("      </devices>\n")
   }
}
END {
      printf("   </probe>\n")
}

