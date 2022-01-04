#!/usr/local/bin/bash
c=`ps -auxwwww | grep msn[2]gwsvr`
c_sub=`ps -auxwwww | grep msn[2]gwsvr |wc -l`
function EST() {
for i in `ps -auxwwww | grep msn[2]gwsvr |awk '{ print $2 }'`; do
        lsof -p $i | grep 5061;
done
}
est_sub=`eval EST |awk '{ print $2 }' |sort |uniq |wc -l`
est_sub1=`eval EST |awk '{print $1,$2,$9,$10}'`
est=`eval EST`
echo "c_sub  : $c_sub"
echo "est_sub: $est_sub"
if [[ "$c_sub" -ne "$est_sub" ]]; then
        echo "You need to do something; and this is why:";
        printf "\n%-s$c\n"
        printf "\n%-s$est_sub1\n"
else
        echo "doing nothing; and this is why:";
        printf "\n%-s$c\n"
        printf "\n%-s$est_sub1\n"
fi
#
## Output Sample
#
-bash-3.2$ bash test
c_sub  :        3
est_sub:        3
doing nothing; and this is why:

yahoo   64906 27.8  3.5 164704 144404  ??  R    Tue01AM 2444:39.67 /home/y/bin/msn2gwsvr /home/y/conf/msngw2/config.0.xml
yahoo   64345 26.8  3.4 162192 141988  ??  R     3:03PM  19:25.59 /home/y/bin/msn2gwsvr /home/y/conf/msngw2/config.2.xml
yahoo   39675 26.0  3.5 164688 144520  ??  S    12Apr12 4393:06.73 /home/y/bin/msn2gwsvr /home/y/conf/msngw2/config.1.xml

msn2gwsvr 64906 sgw124.msn.msg.ac4.yahoo.com:45601->64.4.9.236:5061 (ESTABLISHED)
msn2gwsvr 64345 sgw124.msn.msg.ac4.yahoo.com:45599->64.4.9.236:5061 (ESTABLISHED)
msn2gwsvr 39675 sgw124.msn.msg.ac4.yahoo.com:45598->64.4.9.236:5061 (ESTABLISHED)

A TEST version for full remediation:

#!/usr/local/bin/bash
c=`ps auxwwww | grep msn[2]gwsvr |grep -v grep`
c_sub=`ps auxwwww | grep msn[2]gwsvr |grep -v grep |wc -l`
c_sub1=`echo $c |awk '{ print $2 }'`
function EST() {
for i in `ps auxwwww | grep msn[2]gwsvr |grep -v grep |awk '{ print $2 }'`; do
        lsof -p $i | grep 5061;
done
}
function COMPARE() {
for i in $c_sub1; do
        if [[ "$i" -eq "$est_sub2" ]]; then
                echo "$i is ESTABLISHED"
        else
                echo "$i is not ESTABLISHED, killing $i"
                echo "Testing the kill, not really doing anything..."
        #       sudo kill -9 $i
                echo "re-checking..."
        exit 1
        fi
done
}
est_sub=`eval EST |awk '{ print $2 }' |uniq |wc -l`
est_sub1=`eval EST |awk '{ print $1,$2,$9,$10 }'`
est_sub2=`eval EST |awk '{ print $2 }'`
est=`eval EST`
echo "c_sub  : $c_sub"
echo "est_sub: $est_sub"
if [[ "$c_sub" -ne "$est_sub" ]]; then
        echo "You need to do something; and this is why:";
        echo "Calling the COMPARE() function..."
        COMPARE
        printf "\n%-s$c\n"
        printf "\n%-s$est_sub1\n"
else
        echo "doing nothing; and this is why:";
        printf "\n%-s$c\n"
        printf "\n%-s$est_sub1\n"
fi
