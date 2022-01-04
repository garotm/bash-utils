#!/usr/local/bin/bash
#
# Define Variables
#
SSH="ssh -A -o StrictHostKeyChecking=no"
FSSH="/home/y/bin/fastssh"
F="$HOME/.ssh/authorized_keys"
G="$HOME/.ssh/id_rsa"
#
# Define Banners
#
HEADLINE1="
                _   _  _____       _____             
               | \ | |/ ____|     |  __ \  _     _   
               |  \| | |     _ __ | |__) || |_ _| |_ 
               | .   | |    | '_ \|  ___/_   _|_   _|
               | |\  | |____| | | | |     |_|   |_|  
               |_| \_|\_____|_| |_|_|                
                      Netcool node Parser++
"
echo " ${HEADLINE1} "
echo " "
function ReadParse() {
#
# This is will grab a paste from Netcool and parse out the nodes.
#
echo -n "Paste your Netcool alert(s) then press [CTRL-D] to continue: "
echo " "
#
# Call the PHP script
#
alerts="`php /home/conklin/bin/MODncp++_noyinst`"
#
# This is the command execution aspect
#
colo="`echo ${alerts}`"
# This adds the required ',' for 'fastssh/yinst' formatting
colo_trun="`echo ${alerts} |sed -e 's/[ ]/,/g'`"
#
echo " "
echo " Enter the command you want to execute: "
echo " "
   while read custom_command; do
echo " "
	if [[ ${custom_command} = "fping" || ${custom_command} = "curl" || ${custom_command} = "ping" || ${custom_command} = "ping6" || ${custom_command} = "echo" || ${custom_command} = "rotation" || ${custom_command} = "mtr" ]]; then
        	#for i in ${hostlist[*]}; do
        	for i in ${colo}; do
       	 	${custom_command} ${i}
        	done
     	else
		##
		### Normal looping Implimentation
        	##
		#for i in ${colo}; do
		#echo " "
        	#echo ${i}
       		#${SSH} -i ${G} ${i} ${custom_command}
       		#done
		##
		### 'fastssh' Implimentation
		##
		${FSSH} ${colo_trun} ${custom_command}
       	fi
      	break
   done
echo " "
}
#----------------------------Call It------------------------------------
ReadParse
# EOF