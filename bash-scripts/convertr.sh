#!/usr/local/bin/bash
#:
#: BANNER
#:
echo "
                                  _        
     ___ ___  _ ____   _____ _ __| |_ _ __ 
    / __/ _ \| '_ \ \ / / _ \ '__| __| '__|
   | (_| (_) | | | \ V /  __/ |  | |_| |   
    \___\___/|_| |_|\_/ \___|_|   \__|_|   
        Manhattan Baremetal Converter                             

"
#:
#: Validate input
#:
if [ $# -lt 2 ]; then
        printf "Usage: $0 [<existing host> <new host(s)>]\n\n"
	exit
fi
#:
#: VAR(S)
#:
OLDPH=$1
NEWPH=$2 
NEWLH=$(echo $NEWPH |sed 's/.manhattan/-lh1.manhattan/')
YTAG=$(nova show $OLDPH |awk '/hostname/ {print $4}' |cut -d. -f1)
#:
#: FUNCTION(S)
#:
function confirm() {
if [[ $(nova show $OLDPH &> /dev/null; echo $?) -eq 0 ]]; then
        echo "$OLDPH exists in $(nova show $OLDPH |awk '/status/ {print $4}') state."
        echo "$OLDPH has NOT been deleted."
        echo "***** ABORTING EXECUTION ******"
        echo;
        exit 1;
else
        nova show $OLDPH
        echo "Continuing execution."
fi
}
#:
#: Delete OLDPH
#:
if [[ $(nova show $OLDPH &> /dev/null; echo $?) -eq 0 ]]; then
	nova delete $OLDPH
	while [[ $(nova show $OLDPH &> /dev/null; echo $?) -eq 0 ]]; do 
		printf '\e[1;33m%-6s\e[m\r' "$(nova show $OLDPH |awk '/task_state/ {print $4}')"; 
	done
fi
#:
#: RE-Confirm $OLDPH is deleted
#:
confirm
#:
#: Constuct the conversion string:
#:
nova boot --hint ytag=$YTAG --flavor C-2P-24-500 --image baremetal__RHEL__6.x__64 --hostname $NEWPH,$NEWLH  --availability-zone pda,prod_main,priv,multi --floating-ip-count 1 $NEWPH
echo "Status: $(nova show $NEWPH |awk '/status/ {print $4}')"
echo "If you see a status of 'BUILD' above, the new host is in the building stage and should be ready shorty."
echo "Let's wait a few minutes and then ping them to be sure :)."
#:
#: Check new build is ACTIVE
#:
while [[ $(nova show $NEWPH |grep status |grep -o ACTIVE) != "ACTIVE" ]]; do 
	printf '\e[1;33m%-6s\e[m\r' "$(nova show $NEWPH |awk '/status/ {print $4}')"; 
	sleep 10;
done
printf '\e[1;33m%-6s\e[m\n' "$(nova show $NEWPH |awk '/status/ {print $4}')"
#:
#: Check that host(s) alive
#:
echo "Ping test:"
for i in $NEWPH $NEWLH; do 
	host $i;
	ping -c4 $i; echo
done
#:
#: EOF
#:
