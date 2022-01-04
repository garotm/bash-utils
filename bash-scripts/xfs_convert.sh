#!/usr/local/bin/bash
#: Title        : xfs_convert.sh
#: Date         : 2014-01-22
#: Author       : Garot Conklin
#: Version      : 1.00
#: Description  : Photo/Edge-cache EXT2 to XFS cache fs converter
#: Options      : None
#: BUG          : [Bug 6647519]
#: Runbook      : General
#: Return codes : 2
#:              : 0 = successful
#:              : 1 = failure
#:              :-1 = ambiguous; no execution
#:
#: banner
TITLE="
                  __                 
           __  __/ _|___               
           \ \/ / |_/ __|             
            >  <|  _\__ \               
           /_/\_\_| |___/      _        
  ___ ___  _ ____   _____ _ __| |_       
 / __/ _ \| '_ \ \ / / _ \ '__| __|       
| (_| (_) | | | \ V /  __/ |  | |_          
 \___\___/|_| |_|\_/ \___|_|   \__|        
   EXT2 to XFS conversion utility
"
printf '\n\e[1;33m%-6s\e[m\n\n' "$TITLE"
#: format the hostname and farm number
HNAME=$(uname -n |cut -d. -f1 |tr -d [:digit:]);
FNUMB=$(uname -n |cut -d. -f1 |tr -d [:alpha:] |cut -c 1);

#: grab the filesystem listing
DEVF=$(df -hl |awk '/cache/ {print $1}')

#: backup fstab then change it to reflect XFS
sudo cp /etc/fstab /etc/fstab.EXT2
sed 's/ext2/xfs/' /etc/fstab.EXT2 |sudo tee /etc/fstab

#: confirm
FS=$(awk '/cache/ {print $3}' /etc/fstab |head -1)
if [[ -n $FS ]]; then
    printf '\n\e[1;35m%-6s\e[m\n' "cache in '/etc/fstab' remains $FS: aborting..."
    exit 1;
fi

#: pull from rotation
printf '\n\e[1;35m%-6s\e[m\n' "Taking $(uname -n) out of rotation and stopping services:";
if [[ $HNAME = "cache" ]]; then
    echo y |/home/y/bin/ystatus stop $i;
    for i in nginx ysquid; do
        yinst stop $i;
    done
else
    for i in old_vip vip akamai farm$FNUMB; do
        /home/y/bin/ystatus stop $i;
    done
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

#: pause for 20 seconds to allow executed service stops to fully stop
for i in {20..0}; do
    printf '\e[1;33m%-6s\e[m\r' "Verifying service stop, pausing for $i seconds: "
    sleep 1;
done;
printf '\e[1;33m%-50s\e[m\n' "Complete.";

#: kill off any remaining PIDs
printf '\n\e[1;35m%-6s\e[m\n' "Confirming Service(s) PIDS are dead:";
for i in $(ps auxwww |awk '/[n]ginx: worker process/ {print $2}'); do
  sudo kill -9 $i;
done
for i in $(ps auxwww |awk '/[y]squid/ {print $2}'); do
  sudo kill -9 $i;
done
printf '\e[1;33m%-37s\e[m\n' "Complete.";

#: unmount cache dirs
printf '\n\e[1;35m%-6s\e[m\n' "Unmounting cache/* Filesystems:";
sudo umount /cache*
df -hl
printf '\e[1;33m%-37s\e[m\n' "Complete.";

#: make the new xfs filesystems (LABEL set is NOT tested yet)
n=0; 
for i in $DEVF; do 
  n=$((n+1)); 
  sudo mkfs -t xfs $i; sudo xfs_admin -L CACHE$n $i; 
done

#: confirm LABEL
for i in $DEVF; do
    sudo xfs_admin -l $i;
done

#: mount new xfs filesystem(s)
sudo mount -t xfs -a
xfs_quota -c "df -h" |sort -r |uniq

#: start services
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

#: confirm services are running, if not try to start them again
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

#: place back in rotation
printf '\n\e[1;35m%-6s\e[m\n' "Placing $(uname -n) in rotation:";
if [[ $HNAME = "cache" ]]; then
    echo y |/home/y/bin/ystatus start;
else
    for i in old_vip vip akamai farm$FNUMB; do
        /home/y/bin/ystatus start $i;
    done
fi

#: confirm
printf '\n\e[1;35m%-6s\e[m\n' "Summary:"
xfs_quota -c "df -h" |sort -r |uniq
for i in $DEVF; do
    printf '\n\e[1;33m%-6s\e[m\n' "$(xfs_info $i)";
done
yms-test-checks |sed 's/[ \t]*$//'
exit 0;
#: end of line
