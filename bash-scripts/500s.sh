500s.sh

#: tail /var/log/spread/500_log | awk '{print $1,$5}' |sort -t[ -u +1 -2 |tr -d '[' ; date

WWW=$(grep $(date +%d/%b/%Y) /var/log/spread/500_log | awk '{print $1","}'  |sort |uniq |sed ':a;N;$!ba;s/\n//g')
COUNT=$(grep $(date +%d/%b/%Y) /var/log/spread/500_log | awk '{print $1}' |sort |uniq |wc -l)
SSH="ssh -A -o StrictHostKeyChecking=no"

if [[ $COUNT -gt 10 ]]; then
	printf '\e[1;34m%-6s\e[m\n' "There are $COUNT www's listed here"
	printf '\e[1;34m%-6s\e[m\n' "to many to pull deploy on all at once."
else
	printf '\e[1;34m%-6s\e[m\n' "There are $COUNT www's listed here"
	printf '\e[1;34m%-6s\e[m\n' "Let's pull deploy on the following:"
	printf '\e[1;34m%-6s\e[m\n' "$(grep $(date +%d/%b/%Y) /var/log/spread/500_log | awk '{print $1,$5}' |sort -u -t[ -k1,1 |tr -d '[')"
	yinst ssh -h $WWW "sudo rm /var/www/html/www.flickr.com/local.txt; sudo /sbin/service deploy start" --print --cont
fi
yms-test-checks -s 502_check -c
#: end of line