#!/usr/local/bin/bash
printf "Enter your Netcool alert(s): \n\n";
input=`cat |awk -F"\t" '{ print $7 }'|grep -v Node |sort |uniq`;
printf "\n";
for i in $input; do
        fping $i
done
printf "\n";
exit;