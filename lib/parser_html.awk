#  This file is a part of tool exportProbe
#
#  Coded by: vincenzogianfelice <developer.vincenzog@gmail.com>
#  View my github at https://github.com/vincenzogianfelice

BEGIN {
   FS="|"
   printf("<html>\n")
   printf("<head>\n")
   printf("   <title>Probe Request Data</title>\n")
   printf("   <style>\n")
   printf("      * { font-family: monospace }\n")
   printf("      body {\n")
   printf("         background-color: #f2f2f2\n")
   printf("      }\n")
   printf("      table {\n")
   printf("         width: 100%%;\n")
   printf("      }\n")
   printf("      th, td {\n")
   printf("         border: 2px solid black;\n")
   printf("         padding: 5px;\n")
   printf("      }\n")
   printf("      #mac {\n")
   printf("         font-weight: bold\n")
   printf("      }\n")
   printf("      #essid {\n")
   printf("         font-weight: bold\n")
   printf("      }\n")
   printf("      #header_field {\n")
   printf("         background-color: black;\n")
   printf("         color: white;\n")
   printf("         font-weigth: bold;\n")
   printf("      }\n")
   printf("      #total {\n")
   printf("         border: 0;\n")
   printf("         padding-top: 10px;\n")
   printf("         text-align: left;\n")
   printf("         font-size: 20px;\n")
   printf("      }\n")
   printf("   </style>\n")
   printf("</head>\n")
   printf("<body>\n")
   printf("<h1>Export Data</h1>\n")
   printf("<br />\n")
   printf("   <table align=\"left\">\n")
}
{
   #Header DB
   if ( NR == 1 ) {
      if ( NF > 6 ) {
      	exit 1
      }
   
      #Assign variable header DB
      printf("     <thead>\n") 
      printf("        <th id=\"header_field\">MAC</th>\n") 
      printf("        <th id=\"header_field\">VENDOR</th>\n") 
      printf("        <th id=\"header_field\">SSID</th>\n") 
      printf("        <th id=\"header_field\">DATE</th>\n") 
      printf("        <th id=\"header_field\">RSSI</th>\n") 
      printf("        <th id=\"header_field\">BSSID</th>\n") 
      printf("     </thead>\n")
      printf("     <tbody>\n")
   
   } else {
      #Write parser data DB
      printf("      <tr>\n")
      printf("         <td id=\"mac\">%s</td>\n",$1)
      printf("         <td>%s</td>\n",$2)
      printf("         <td id=\"essid\">%s</td>\n",$3)
      printf("         <td>%s</td>\n",$4)
      printf("         <td>%s</td>\n",$5)
      printf("         <td>%s</td>\n",$6)
      printf("      </tr>\n")
   }
}
END {
   printf("      </tbody>\n")
   printf("      <tfoot>\n")
   printf("         <th id=\"total\">Totals Devices: %s</th>\n", NR-1)
   printf("      </tfoot>\n")
   printf("   </table>\n")
   printf("</body>\n")
   printf("</html>\n")
}
