cm3-fix.sh

#!/usr/local/bin/bash
STAT='sudo -u root /home/y/libexec/ymon/check_cm3_client'
STAT1='sudo -u root /home/y/libexec/ymon/check_cm3_client |grep -o OK'
if [[ "$(eval $STAT1)" != "OK" ]]; then
        eval $STAT
        echo "Fixing CM3:"
        sudo /var/cm3/bin/svc -d /var/cm3/service/cm3_client
        sudo /var/cm3/bin/svc -d /var/cm3/service/cm3_client_sync
        sudo rm /var/cm3/data
        sudo rm -r /var/cm3/data.rsync
        sudo /var/cm3/bin/svc -u /var/cm3/service/cm3_client
        sudo /var/cm3/bin/svc -u /var/cm3/service/cm3_client_sync
        if [[ "$(eval $STAT1)" = "OK" ]]; then
                echo "CM3 is $(eval $STAT1)"
        else
                echo "CM3 isse was not resolved:"
                eval $STAT
        fi
else
        echo "CM3 is $(eval $STAT1)"
fi