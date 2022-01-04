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
printf "%-1s--*$var Statserver Port: $x*--\n"
statserver -t 10 localhost $x 1
printf "%-25s-----*logs*-----\n"
# find the correct log dir
log_dir=`sudo find /home/y/logs/* -name ${var}.err`
log_dir_archive=`sudo find /home/y/logs/* -name ${var}.err.1`
# Account for a possibility of more than one finding here
function Log_Check() {
    if [ -z $log_dir $log_dir_archive ]; then
        echo "No Relevant Logs found."
    else
        for i in `echo $log_dir $log_dir_archive`; do
            echo $i 
            grep -E 'no proxy|lost proxy connection for proxy|discarding all' $i |sort |uniq |tail -15
            date
        done
    fi
}
Log_Check
printf "%-25s-----*Failed Nodes Re_Established*-----\n"
function Failed_Node_Check() {
lc=$(Log_Check)
    if [[ -n $lc ]]; then
        echo "No Re-Established nodes found."
    else
        for i in $lc; do
            echo $i |awk -F '(' '{ print $2 }' |cut -d: -f1 |sed '/^$/d' |grep -v server
        done
    fi
}
fnc=$(Failed_Node_Check)
for i in $fnc; do
        /home/y/bin/pgall localhost $x |grep $i
done
echo ""
printf "%-13s-----*Server Checks*-----\n"
for i in `ls -1 /home/y/bin/ |grep "[-]check"`; do
        printf "%-10s-----*${i}*-----\n"
        ${i}
        printf "%-10s-----*END*-----\n"
done
printf "%-15s-----*Pgall Checks*-----\n"
/home/y/bin/pgall localhost $x |grep -v "state: connected, enabled" |more
echo "      -=-=-=-=-=-END=-=-=-=-=-=- "
echo ""
}
case "$1" in
       [a-zA-Z]*) Client_Group_server ;;
        *) echo "Usage: $0 [client-group-server]" ;;
esac
# EOF

-bash-3.2$ for i in $(/home/y/bin/pgall localhost 17753 |grep pid |awk '{print $6}' |cut -d, -f1); do ps auxwww |grep $i |grep -v grep; done |sort -k12 -n
root     26952  0.0  0.0  38100 22496 ?        S    Aug02  21:52 /home/y/bin/connBroker /home/y/conf/connBroker/connBroker.xml
yahoo    26977  0.0  1.2 433912 306584 ?       S    Aug02  42:45 /home/y/bin/requestBroker 0 /home/y/conf/requestBroker/requestBroker.xml
yahoo    27017  0.0  1.2 434280 307272 ?       S    Aug02  42:46 /home/y/bin/requestBroker 1 /home/y/conf/requestBroker/requestBroker.xml
yahoo    27020  0.0  1.2 434088 307156 ?       S    Aug02  42:44 /home/y/bin/requestBroker 2 /home/y/conf/requestBroker/requestBroker.xml
yahoo    26919  0.0  1.2 433720 308764 ?       S    Aug02  41:42 /home/y/bin/requestBroker 3 /home/y/conf/requestBroker/requestBroker.xml
yahoo    26905  0.0  1.2 434216 307760 ?       S    Aug02  41:35 /home/y/bin/requestBroker 4 /home/y/conf/requestBroker/requestBroker.xml
yahoo    27023  0.0  1.2 433892 306680 ?       S    Aug02  42:46 /home/y/bin/requestBroker 5 /home/y/conf/requestBroker/requestBroker.xml
yahoo    26973  0.0  1.2 433828 306640 ?       S    Aug02  42:44 /home/y/bin/requestBroker 6 /home/y/conf/requestBroker/requestBroker.xml
yahoo    27116  0.0  1.2 433892 306672 ?       S    Aug02  41:35 /home/y/bin/requestBroker 7 /home/y/conf/requestBroker/requestBroker.xml
yahoo    27122  0.0  1.2 433724 306896 ?       S    Aug02  42:49 /home/y/bin/requestBroker 8 /home/y/conf/requestBroker/requestBroker.xml
yahoo    26971  0.0  1.2 433828 307144 ?       S    Aug02  42:48 /home/y/bin/requestBroker 9 /home/y/conf/requestBroker/requestBroker.xml
yahoo    26937  0.0  1.2 434248 306816 ?       S    Aug02  42:05 /home/y/bin/requestBroker 10 /home/y/conf/requestBroker/requestBroker.xml
yahoo    27217  0.0  1.2 434008 306976 ?       S    Aug02  42:44 /home/y/bin/requestBroker 11 /home/y/conf/requestBroker/requestBroker.xml
yahoo    26975  0.0  1.2 433572 305712 ?       S    Aug02  42:44 /home/y/bin/requestBroker 12 /home/y/conf/requestBroker/requestBroker.xml
yahoo    27226  0.0  1.2 433752 306860 ?       S    Aug02  42:14 /home/y/bin/requestBroker 13 /home/y/conf/requestBroker/requestBroker.xml
yahoo    27242  0.0  1.2 433928 306696 ?       S    Aug02  42:52 /home/y/bin/requestBroker 14 /home/y/conf/requestBroker/requestBroker.xml
yahoo    26956  0.0  1.2 433948 306948 ?       S    Aug02  42:30 /home/y/bin/requestBroker 15 /home/y/conf/requestBroker/requestBroker.xml

