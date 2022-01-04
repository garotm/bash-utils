#!/usr/local/bin/bash
#:
#: Get the checks
#:
ALL_CHECKS=$(curl -s localhost:8081/healthcheck |json_pp |tr -d '[:punct:]' |egrep -v 'healthy|message' |tr  -d '[:cntrl:]');
API_CHECKS=$(for x in $ALL_CHECKS; do echo $x |grep -oEi 'audit|deadlocks|.*.database|database'; done |sort)
printf '\n\e[1;34m%-6s\e[m\n\n' "     --- Validating Service Checks ---"
#:
#: Loop and qualify the checks
#:
for i in $API_CHECKS; do
	RESULT=$(curl -s localhost:8081/healthcheck |json_pp |tr -d '[:punct:]' |grep -v message |grep -A1 $i |awk '/healthy/ {print $2}')
	if [[ "$RESULT" -ne "true" ]]; then
		printf '\e[1;31m%-6s\e[m\n' "$i: CHECK BAD"
		curl -s localhost:8081/healthcheck |json_pp |tr -d '[:punct:]' |grep -A2 $i
		ENDPOINTS=$(cat audit |grep message |tr -d [:alpha:] |cut -d / -f3-5 |tr ',//' ' ' |awk -F: '{print $1":"$2,$3":"$4}' |cut -d ')' -f1)
		#: Take a look at dwamq endpoints
		printf '\n\e[1;31m%-6s\e[m\n\n' "Checking DWAMQ Endpoints:"
		for i in $ENDPOINTS; do
			curl -v -m 10 $i/admin;
		done
		#: Restart the 'spaces-api' service
		printf '\e[1;31m%-6s\e[m\n' "Restarting the 'spaces-api' service:"
		service spaces-api restart
		#: Sleep 10, then revalidate the checks
		for i in {10..0}; do
    			printf '\e[1;33m%-6s\e[m\r' "Verifying 'spaces-api' service, pausing for $i seconds: "
    			sleep 1;
		done;
		printf '\e[1;33m%-60s\e[m\n\n' "Complete."
		printf '\e[1;33m%-6s\e[m\n\n' "Post Validation:"
		for i in $API_CHECKS; do
			if [[ "$(eval $RESULT)" -eq "true" ]]; then
				printf '\e[1;32m%-20s\e[m: CHECK OK\n' "$i"
			else
				printf '\e[1;31m%-6s\e[m\n' "$i: CHECK BAD"
			fi
		done
	else
		printf '\e[1;32m%-20s\e[m: CHECK OK\n' "$i"
	fi;
done
printf '\n\e[1;34m%-6s\e[m\n\n' "                ---END---"
exit 0;
#:
#: EOF
#:
