# exportProbe
*Export data from tool **probeSniffer.py** (https://github.com/xdavidhu/probeSniffer)*

# Depend

- sqlite3

# Usage

*./exportProbe.sh -h*

```
                                _   ____            _          
      _____  ___ __   ___  _ __| |_|  _ \ _ __ ___ | |__   ___ 
     / _ \ \/ / '_ \ / _ \| '__| __| |_) | '__/ _ \| '_ \ / _ \
    |  __/>  <| |_) | (_) | |  | |_|  __/| | | (_) | |_) |  __/
     \___/_/\_\ .__/ \___/|_|   \__|_|   |_|  \___/|_.__/ \___|
               |_|


Usage: ./exportProbe.sh -d file.db [ -r | -e | -n ] | -h

Options:
-d <file>       Database file
-f              Force read DB in case of error
-r              Print raw DB
-e              Print only devices with an SSID
-n              Print only devices that have null SSID field
-M              Print only devices that do not have a MAC vendor
-E              Print only devices that have correct SSID and MAC vendor field
-B              Print without broadcast devices
-D              Remove duplicate lines
-S              Sort for ESSID
-h              Show this help
-m              Search Vendor MAC Address for devices that were not found
                The file default is 'oui.txt'
```

# Donazioni

**BTC:** *3EwV4zt9r5o4aTHyqjcM6CfqSVirSEmN6y*

# Contatti

**Email:** *developer.vincenzog@gmail.com*
