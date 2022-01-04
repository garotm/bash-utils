#!/usr/local/bin/bash
#: Title        : cache-cleaner
#: Date         : 2013-11-13
#: Author       : Garot Conklin
#: Version      : 1.01
#: Description  : Generalized FLICKR *cache host filesystem cleaner
#: Options      : None
#: BUG          : [bug TBD]
#: Runbook      : General
#: Return codes : 2
#:              : 0   = successful
#:              : 1   = failure
#:              :-1   = ambiguous; no execution
#:
#: GLOBALS
#:
HNAME=$(uname -n |cut -d. -f1 |sed 's/[0-9]*//g' |cut -c 1-5);
ST=$(date);

printf '\n\e[1;35m%-6s\e[m\n' "PRE State Summary:";
for fs in $(df -hl |grep dev |awk '{print $1}'|egrep -v 'hnas|nas|tmpfs|tmp|nfs|swap|swp|none|filer'); do
    echo "$fs: $(sudo /sbin/tune2fs -l $fs |grep 'Filesystem state:')";
done

#: Take it OOR
printf '\n\e[1;35m%-6s\e[m\n' "Taking $(uname -n) out of rotation:";
if [[ $HNAME = "cache" ]]; then
	echo y |/home/y/bin/ystatus stop $i;
else
	for i in old_vip vip akamai farm$(uname -n |cut -d '.' -f1 |sed 's/[^0-9]//g' |cut -c 1); do
    	/home/y/bin/ystatus stop $i;
	done
fi

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

#: Pause for a few to allow executed service stops to fully stop
for i in {10..0}; do
	printf '\e[1;33m%-6s\e[m\r' "Verifying service stop, pausing for $i "
	sleep 1;
done;
printf '\e[1;33m%-6s\e[m\r' "Complete.                            ";
echo

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
			yinst stop $i;
		done
	fi
fi

#: Put it in rotation
printf '\n\e[1;35m%-6s\e[m\n' "Taking $(uname -n) out of rotation:";
if [[ $HNAME = "cache" ]]; then
	echo y |/home/y/bin/ystatus start $i;
else
	for i in old_vip vip akamai farm$(uname -n |cut -d '.' -f1 |sed 's/[^0-9]//g' |cut -c 1); do
    	/home/y/bin/ystatus start $i;
	done
fi

printf '\n\e[1;35m%-6s\e[m\n' "POST State Summary:";
for fs in $(df -hl |grep dev |awk '{print $1}'|egrep -v 'hnas|nas|tmpfs|tmp|nfs|swap|swp|none|filer'); do
    echo "$fs: $(sudo /sbin/tune2fs -l $fs |grep 'Filesystem state:')";
done
ET=$(date)
printf '\n\e[1;35m%-6s\e[m\n' "Start Time: $ST";
printf '\e[1;35m%-6s\e[m\n\n' "End Time: $ET";

yms-test-checks -c