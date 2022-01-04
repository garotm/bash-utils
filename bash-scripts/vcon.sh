vcon.sh

function vcon() {
if [ $# -lt 1 ]; then
        echo "Usage: $0 [FQDN of VESPA controller]"
        echo "$0 vcon1.flickr.ac4.yahoo.com"
else
        printf '\n\e[1;32m%-6s\e[m\n' "    VCON OOS Listing"
        printf '\e[1;32m%-6s\e[m\n' "    ----------------"
        ssh $1 "/home/y/bin/rtx-cmd --cluster=flickrphotos getOOSList 0 0 |grep 'string:'"
        echo;
fi
}