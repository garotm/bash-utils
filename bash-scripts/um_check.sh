#!/usr/local/bin/bash
if [ $# -lt 1 ]; then
        echo "Usage: $0 [client-group-server]"
        exit
fi
var=$1
#
## Function(s)
#
function Client_Group_server() {
#
function X() {
for i in `sudo find /home/y/conf/* -name *.procinfo`;
        do grep $var $i |awk '{ print $4 }'
done
}
x=`eval X`
if [ -z "$x" ]; then
function X() {
for i in `sudo find /home/y/conf/* -name *.procinfo`;
        do grep http $i |awk '{ print $2 }' |xargs /home/var/cm3/bin/curl -s |grep $var |awk '{ print $4 }'
done
}
x=`eval X`
fi
echo ""
printf "%15s--*Groucho verify*--\n"
sudo groucho -n; echo ""
printf "%-2s--*$var Statserver*--\n"
statserver -t 10 localhost $x 1
printf "%-25s-----*logs*-----\n"
grep "discarding all" /home/y/logs/ymcacheproxy/${var}.err |tail -10
date
}
case "$1" in
       [a-zA-Z]*) Client_Group_server ;;
        *) echo "Usage: $0 [client-group-server]" ;;
esac
# EOF

Sample Output:

-bash-3.2$ bash um_check.sh localhost_ATOBYMCACHE_srv

               --*Groucho verify*--
um101a.msg.ac4.yahoo.com        groucho_proc_ext        0       all: OK
um101a.msg.ac4.yahoo.com        groucho_logs    0       all: OK
um101a.msg.ac4.yahoo.com        groucho_ps      0       all: OK
um101a.msg.ac4.yahoo.com        groucho_procs   0       all: OK
um101a.msg.ac4.yahoo.com        groucho_gen     0       all: OK
um101a.msg.ac4.yahoo.com        groucho_shells  0       all: OK

  --*localhost_ATOBYMCACHE_srv Statserver*--
-------------------------------------------------
InRate=[0] OutRate=[280] MsgQueue=[0] InBytes=[0] OutBytes=[367158] TotalBytes=[367158] DropRate=[0] DropBytes[0]
InRate=[0] OutRate=[281] MsgQueue=[0] InBytes=[0] OutBytes=[340733] TotalBytes=[340733] DropRate=[0] DropBytes[0]
InRate=[0] OutRate=[269] MsgQueue=[0] InBytes=[0] OutBytes=[355423] TotalBytes=[355423] DropRate=[0] DropBytes[0]
InRate=[0] OutRate=[296] MsgQueue=[0] InBytes=[0] OutBytes=[387662] TotalBytes=[387662] DropRate=[0] DropBytes[0]
InRate=[0] OutRate=[317] MsgQueue=[0] InBytes=[0] OutBytes=[394874] TotalBytes=[394874] DropRate=[0] DropBytes[0]
InRate=[0] OutRate=[271] MsgQueue=[0] InBytes=[0] OutBytes=[359751] TotalBytes=[359751] DropRate=[0] DropBytes[0]
InRate=[0] OutRate=[270] MsgQueue=[0] InBytes=[0] OutBytes=[334511] TotalBytes=[334511] DropRate=[0] DropBytes[0]
InRate=[0] OutRate=[327] MsgQueue=[0] InBytes=[0] OutBytes=[395900] TotalBytes=[395900] DropRate=[0] DropBytes[0]
InRate=[0] OutRate=[305] MsgQueue=[0] InBytes=[0] OutBytes=[398678] TotalBytes=[398678] DropRate=[0] DropBytes[0]
InRate=[0] OutRate=[265] MsgQueue=[0] InBytes=[0] OutBytes=[365762] TotalBytes=[365762] DropRate=[0] DropBytes[0]
                         -----*logs*-----
Fri Apr 13 19:50:14 2012: queue overflow; discarding all 757 messages for client -1 group ATOBYMCACHE (server)
Sat Apr 14 12:00:04 2012: queue overflow; discarding all 771 messages for client -1 group ATOBYMCACHE (server)
Sat Apr 14 15:45:14 2012: queue overflow; discarding all 774 messages for client -1 group ATOBYMCACHE (server)
Sat Apr 14 15:53:03 2012: queue overflow; discarding all 742 messages for client -1 group ATOBYMCACHE (server)
Sun Apr 15 12:00:04 2012: queue overflow; discarding all 732 messages for client -1 group ATOBYMCACHE (server)
Sun Apr 15 13:55:03 2012: queue overflow; discarding all 820 messages for client -1 group ATOBYMCACHE (server)
Sun Apr 15 15:40:03 2012: queue overflow; discarding all 813 messages for client -1 group ATOBYMCACHE (server)
Sun Apr 15 15:58:48 2012: queue overflow; discarding all 754 messages for client -1 group ATOBYMCACHE (server)
Sun Apr 15 17:55:15 2012: queue overflow; discarding all 787 messages for client -1 group ATOBYMCACHE (server)
Sun Apr 15 17:57:04 2012: queue overflow; discarding all 798 messages for client -1 group ATOBYMCACHE (server)
Sun Apr 15 18:28:41 UTC 2012


curl check:
-bash-3.2$ var="localhost_UPDATEUM_svr"
-bash-3.2$ for i in `sudo find /home/y/conf/* -name *.procinfo`; do grep http $i |awk '{print $2 }' |xargs /home/var/cm3/bin/curl -s |grep $var |awk '{ print $4 }';  done
9425
#
## hmmm... using /home/y/bin/ymcacheproxy-check, you can get ALL pertinent servers running on a host... interesting idea to use that...
#
This will only work as a function (due to the oddness of it all) and it will need to 'plug-in' to the URL parsing logic as well...
#
-bash-3.2$ for var in `/home/y/bin/ymcacheproxy-check 2>&1 |awk '{ print $2 }' |cut -d'.' -f1`; do for i in `sudo find /home/y/conf/* -name *.procinfo`; do grep $var $i |awk '{print $4 }'; done; done   
6448
7448
#
## Check if a command actually exists; have not figured out how to test flags however
#
-bash-3.2$ if command -v statserver 2&>1; then echo "1"; else echo "2"; fi
1
-bash-3.2$ if command -v junk 2&>1; then echo "1"; else echo "2"; fi
2
