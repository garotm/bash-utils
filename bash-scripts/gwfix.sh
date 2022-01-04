#!/usr/local/bin/bash
if [ $# -lt 1 ]; then
        echo "Usage: $0 [provider gateway]"
        exit
fi
var=$1
function Provider_Gateway_Fix() {
echo "";
uname -n;
date;
perl -e 'print "-" x 28,"\n"';
/home/y/bin/${var}cons-check;
sudo -u yahoo smsgateway-restart ${var};
sleep 5;
sudo -u yahoo /home/y/bin/${var}cons-restart;
sleep 10;
echo "";
echo "Verifying groucho...";
perl -e 'print "-" x 20,"\n"';
sudo groucho -n;
echo "";
echo "Verifying the 'cons' gateway...";
perl -e 'print "-" x 31,"\n"';
/home/y/bin/${var}cons-check;
echo ""
#
}
case "$1" in
       [a-zA-Z]*) Provider_Gateway_Fix ;;
        *) echo "Usage: $0 [provider gateway]" ;;
esac
# EOF