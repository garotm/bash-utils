pc-clean

ST=$(date);
printf '\n\e[1;35m%-6s\e[m\n' "PRE State Summary:";
for fs in $(df -hl |grep dev |awk '{print $1}'|egrep -v 'hnas|nas|tmpfs|tmp|nfs|swap|swp|none|filer'); do
    echo "$fs: $(sudo /sbin/tune2fs -l $fs |grep 'Filesystem state:')";
done

printf '\n\e[1;35m%-6s\e[m\n' "Taking $(uname -n) out of rotation:";
for i in old_vip vip akamai farm$(uname -n |cut -d '.' -f1 |sed 's/[^0-9]//g' |cut -c 1); do
    /home/y/bin/ystatus stop $i;
done

printf '\n\e[1;35m%-6s\e[m\n' "Stopping Services:";
for i in nginx ysquid ysquid_prime; do
	yinst stop $i;
done

#: Pause for a few to allow things to fully stop
for i in {10..0}; do
	printf '\e[1;33m%-6s\e[m\r' "Verifying service stop, pausing for $i "
	sleep 1;
done; echo

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

printf '\n\e[1;35m%-6s\e[m\n' "Mounting Filesystems:";
df -hl
sudo mount -t ext2 -a

printf '\n\e[1;35m%-6s\e[m\n' "Starting Services:";
for i in nginx ysquid ysquid_prime; do
	yinst start $i;
done

printf '\n\e[1;35m%-6s\e[m\n' "Placing $(uname -n) back in rotation:";
for i in old_vip vip akamai farm$(uname -n |cut -d '.' -f1 |sed 's/[^0-9]//g' |cut -c 1); do
    /home/y/bin/ystatus start $i;
done

printf '\n\e[1;35m%-6s\e[m\n' "POST State Summary:";
for fs in $(df -hl |grep dev |awk '{print $1}'|egrep -v 'hnas|nas|tmpfs|tmp|nfs|swap|swp|none|filer'); do
    echo "$fs: $(sudo /sbin/tune2fs -l $fs |grep 'Filesystem state:')";
done
ET=$(date)
printf '\n\e[1;35m%-6s\e[m\n' "Start Time: $ST";
printf '\e[1;35m%-6s\e[m\n\n' "End Time: $ET";

yms-test-checks -c