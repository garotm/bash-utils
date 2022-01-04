cache-cleaner.sh

#!/usr/local/bin/bash
#: Title : cache-cleaner
#: Date : 2013-11-13
#: Author : Garot Conklin
#: Version : 1.01
#: Description : Generalized FLICKR *cache host filesystem cleaner
#: Options : None
#: BUG : [bug 6647519]
#: Runbook : General
#: Return codes : 1
#: : 0 = successful
#: : 1 = failure
#: :-1 = ambiguous; no execution
#:
#: Hostname clipper
HNAME=$(uname -n |cut -d. -f1 |tr -d [:digit:]);
FNUMB-$(uname -n |cut -d. -f1 |tr -d [:alpha:] |cut -c 1);

TOTAL=$(for i in $(vipcheck |cut -d: -f1); do rotation $i -all |grep -v vip; done |wc -l);
UP=$(for i in $(vipcheck |cut -d: -f1); do rotation $i -brief; done |wc -l);
DOWN=$(for i in $(vipcheck |cut -d: -f1); do rotation $i -down |grep -v vip; done |wc -l);
PRCT=$(echo "scale=2; $DOWN / $TOTAL * 100" | bc);
RAWN=$(echo "scale=0; $DOWN / $TOTAL * 100" | bc);

if [[ $UP -eq $TOTAL ]]; then
    printf '\n\e[1;32m%-6s\e[m\n' "Farm$FNUMB is 100% in rotation, continuing execution.";
    vipcheck;
elif [[ $RAWN -le 25 ]]; then
    printf '\n\e[1;32m%-6s\e[m\n' "$(echo "scale=2; $DOWN / $TOTAL * 100" | bc)% of Farm$FNUMB is OOR which is < 25% of all hosts in the VIP, continuing execution."
    vipcheck;
else
    printf '\n\e[1;31m%-6s\e[m\n' "$(echo "scale=2; $DOWN / $TOTAL * 100" | bc)% of Farm$FNUMB is OOR, aborting."
    vipcheck;
    exit 1;
fi

#: Start Stamp
ST=$(date);

printf '\n\e[1;35m%-6s\e[m\n' "PRE State Summary:";
for fs in $(df -hl |awk '/cache/ {print $1}'); do
    echo "$fs: $(sudo /sbin/tune2fs -l $fs |grep 'Filesystem state:')";
done

#: Take it OOR
printf '\n\e[1;35m%-6s\e[m\n' "Taking $(uname -n) out of rotation:";
if [[ $HNAME = "cache" ]]; then
    echo y |/home/y/bin/ystatus stop $i;
else
    for i in old_vip vip akamai farm$FNUMB; do
        /home/y/bin/ystatus stop $i;
    done
fi

#: Stop Services
printf '\n\e[1;35m%-6s\e[m\n' "Stopping Services:";
if [[ $HNAME = "cache" ]]; then
    for i in nginx ysquid; do
        yinst stop $i;
    done
else
    if [[ -z $(yinst ls |grep [y]squid_prime-) ]]; then
        for i in nginx ysquid; do
            yinst stop $i;
        done
    else
        for i in nginx ysquid ysquid_prime; do
            yinst stop $i;
        done
    fi
fi

#: Pause for 20 seconds to allow executed service stops to fully stop
for i in {10..0}; do
    printf '\e[1;33m%-6s\e[m\r' "Verifying service stop, pausing for $i "
    sleep 2;
done;
printf '\e[1;33m%-37s\e[m\n' "Complete.";

#: Kill off any remaining PIDs
printf '\n\e[1;35m%-6s\e[m\n' "Confirming Service(s) PIDS are dead:";
    for i in $(ps auxwww |awk '/[n]ginx: worker process/ {print $2}'); do
        sudo kill -9 $i;
    done

for i in $(ps auxwww |awk '/[y]squid/ {print $2}'); do
    sudo kill -9 $i;
done

printf '\n\e[1;35m%-6s\e[m\n' "Unmounting cache/* Filesystems:";
sudo umount /cache*

printf '\n\e[1;35m%-6s\e[m\n' "Executing FSCK:";
sudo fsck -f -y /cache* &> /dev/null
printf '\e[1;35m%-6s\e[m\n' "FSCK Complete."

printf '\n\e[1;35m%-6s\e[m\n' "Mounting Filesystems:";
sudo mount -t ext2 -a
df -hl

printf '\n\e[1;35m%-6s\e[m\n' "Starting Services:";
if [[ $HNAME = "cache" ]]; then
    for i in nginx ysquid; do
        yinst start $i;
    done
else
    if [[ -z $(yinst ls |grep [y]squid_prime-) ]]; then
        for i in nginx ysquid; do
        yinst start $i;
        done
    else
        for i in nginx ysquid ysquid_prime; do
        yinst start $i;
    done
    fi
fi

#: Confirm services are running, if not try to start them again
if [[ -z $(ps auxwww |awk '/[n]ginx: worker process/ {print $2}') ]]; then
    printf '\n\e[1;35m%-6s\e[m\n' "nginx did not start as expected, retrying..."
    yinst restart nginx;
fi

if [[ -z $(ps auxwww |awk '/[y]squid/ {print $2}') ]]; then
    printf '\n\e[1;35m%-6s\e[m\n' "ysquid did not start as expected, retrying..."
    yinst restart ysquid;
fi

if [[ -n $(yinst ls |grep [y]squid_prime-) ]]; then
    if [[ -z $(ps auxwww |awk '/[y]squid_prime/ {print $2}') ]]; then
        printf '\n\e[1;35m%-6s\e[m\n' "ysquid_prime did not start as expected, retrying..."
        yinst restart ysquid_prime;
    fi
fi

#: Put it in rotation
printf '\n\e[1;35m%-6s\e[m\n' "Placing $(uname -n) in rotation:";
if [[ $HNAME = "cache" ]]; then
    echo y |/home/y/bin/ystatus start;
else
    for i in old_vip vip akamai farm$FNUMB; do
        /home/y/bin/ystatus start $i;
    done
fi

printf '\n\e[1;35m%-6s\e[m\n' "POST State Summary:";
for fs in $(df -hl |awk '/cache/ {print $1}'); do
    echo "$fs: $(sudo /sbin/tune2fs -l $fs |grep 'Filesystem state:')";
done

#: End Stamp
ET=$(date)
printf '\n\e[1;35m%-6s\e[m\n' "Start Time: $ST";
printf '\e[1;35m%-6s\e[m\n\n' " End Time: $ET";

printf '\n\e[1;35m%-6s\e[m\n' "Host State Verification:"
/home/y/bin/yms-test-checks -c

printf '\n\e[1;35m%-6s\e[m\n\n' " --- Execution Complete --- "
exit 0;