#!/usr/local/bin/bash
#: Title        : swap-check
#: Date         : 2016-06-17
#: Author       : Garot Conklin
#: Version      : 1.00
#: Description  : Generalized swap usage check
#: Options      : N/A
#: Return codes : 0
#:              : 0 = successful
#:              : 1 = failure
#:              :-1 = ambiguous; no execution
#:
function swap_check() {
#:
#: run with 'sudo'
#: Similar to $(top -O -p in execution mode)
#: Pipe the output to "sort -nk3" to get sorted output
#:
#: Summary
#:
vmstat -S m; echo;
free -m; echo;
#:
swap_total=0
for i in /proc/[0-9]*; do
	pid=$(echo $i | sed -e 's/\/proc\///g')
	swap_pid=$(cat /proc/$pid/smaps |
	awk 'BEGIN{total=0}/^Swap:/{total+=$2}END{print total}')
	if [ "$swap_pid" -gt 0 ]; then
		name=$(cat /proc/$pid/status | grep ^Name: |
		awk '{print $2}')
		echo "${name} (${pid}) ${swap_pid} kB"
		let swap_total+=$swap_pid
	fi
done;
printf "\nTotal swap: ${swap_total} kB\n\n"
}
swap_check;
#:
#: EOF
#:

