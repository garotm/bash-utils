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
                        _ __   ___
        _ __   __ _ ___| |\ \ / / |
       | '_ \ / _\ / __| __\ V /| |
       | |_) | (_| \__ \ |_ | | |_|
       | .__/ \__,_|___/\__||_| (_)
       |_|  shelli_paster v0.1-1
"
echo " ${HEADLINE1} "
echo " "
#
function Netcool() {
#
# This is will grab a paste from Netcool and parse out the nodes.
#
echo -n "Paste your Netcool alert(s) then press [CTRL-D] to continue: "
echo " "
echo " "
#
# Call the PHP script; modified to use dhubbard's
# 'fastssh' (requires ','s between node listings)
#
alerts="`php /home/conklin/bin/shelli_parse.php`"
colo="`echo ${alerts} |sed -e 's/[ ]/,/g'`"
}
function Manual_Host() {
echo " "
echo "     Enter a host or range of hosts: "
echo " "
read colo
}
#
# Sub-Functions
#
function Exceptions() {
for i in ${colo}; do
        ${custom_command} ${i}
done
}
# ----END-SUB-Exceptions
function Curler() {
for i in ${colo}; do
        echo "akamai: `${custom_command} http://${i}/akamai`"
        echo "status.html: `${custom_command} http://${i}/status.html`"
        ${custom_command} http://${i}/status |grep "<PRE>"
        echo "       <|------------END------------|> "
done
}
# ----END-SUB-Curler
function Faster() {
##
### 'fastssh' Implimentation
##
${FSSH} ${colo} "${custom_command}"
}
# ----END-SUB-Faster
#
# Messenger Hosts
#
captchaes='captchaes[201-203].chat.ac4'
cha_dev='cha[1-2].orl.msg.sp1'
cha_prod='cha[101-124].msg.[ac4,sp2]'
cha_qa='cha[101-102].[sea,phx].msg.ne1'
cs='cs[201-220].msg.[ac4,sp1].yahoo.com'
es_all='es[101-180].msg.[ac4,sp1]'
es_login='es[101-140].msg.[ac4,sp1]'
es_msg='es[141-180].msg.[ac4,sp1]'
gwes='gwes[101-109].msn.msg.ac4'
httpcs='httpcs[101-106].wg.msg.sp1'
ies='ies[101-107].iop.msg.[ac4,sp1]'
in='in[201-215].msg.[ac4,sp1]'
mmguest='mmguest[101-103].msg.[ac4,sp1]'
mmwapab='mmwapbp[201-204].msg.[ac4,sp1]'
pes='pes[101-106].msg.[ac4,sp2]'
pws='pws[101-106].msg.ac4'
rbes='rbes[101-125].msg.ac4'
rcns='rcns[101-113][a,b].msg.[ac4,sp2]'
rdis='rdis[101-107].msg.[ac4,sp1]'
rws='rws[101-120].msg.[ac4,sp2]'
webapp='webapp[101-104].msg.[ac4,ukl]'
#
# Messenger_Pools Function
#
function Messenger_Pools() {
select nodes in captchaes cha_dev cha_prod cha_qa cs es_all es_login es_msg gwes httpcs ies in mmguest mmwapab pes pws rbes rcns rdis rws webapp EXIT; do
        case $REPLY in
                1 ) colo=$captchaes ;;
                2 ) colo=$cha_dev ;;
                3 ) colo=$cha_prod ;;
                4 ) colo=$cha_qa ;;
                5 ) colo=$cs ;;
                6 ) colo=$es_all ;;
                7 ) colo=$es_login ;;
                8 ) colo=$es_msg ;;
                9 ) colo=$gwes ;;
                10 ) colo=$httpcs ;;
                11 ) colo=$ies ;;
                12 ) colo=$in ;;
                13 ) colo=$mmguest ;;
                14 ) colo=$mmwapab ;;
                15 ) colo=$pes ;;
                16 ) colo=$pws ;;
                17 ) colo=$rbes ;;
                18 ) colo=$rcns ;;
                19 ) colo=$rdis ;;
                20 ) colo=$rws ;;
                21 ) colo=$webapp ;;
                22 ) colo='exit' ;;
        esac
Body
done
}
function Body() {
#
echo " "
echo " Enter the command(s) you want to execute: "
echo " "
   while read custom_command; do
echo " "
        if [[ ${custom_command} = "fping" || ${custom_command} = "ping" || ${custom_command} = "ping6" || ${custom_command} = "dig" || ${custom_command} = "nslookup" || ${custom_command} = "echo" || ${custom_command} = "rotation" || ${custom_command} = "mtr" ]]; then
                Exceptions
                break
        elif [[ ${custom_command} = "curl" ]]; then
                Curler
                break
        else
                Faster
                break
        fi
   done
echo " "
}
function Help_Us() {
echo "   ------
   USAGE:
   help - This menu.
   main - Return to the main menu.
   cmd  - Return to the command-entry point.
   ----------------------------------------- "
}
#
# Setup the Main options
#
function Main_line() {
select option in "Netcool" "Host Entry" "Host Pools" EXIT; do
        case $REPLY in
                1 ) OPTION=Netcool ;;
                2 ) OPTION=Manual_Host ;;
                3 ) OPTION=Messenger_Pools ;;
                4 ) OPTION='exit' ;;
                cmd ) Body ;;
                main ) Main_line ;;
                help ) Help_Us ;;
                clear ) clear ;;
                exit ) exit ;;
                * )
        esac
if [ $REPLY = "1" ]; then
        Netcool
        Body
elif [ $REPLY = "2" ]; then
        Manual_Host
        Body
elif [ $REPLY = "3" ]; then
        Messenger_Pools
        Body
elif [ $REPLY = "4" ]; then
        exit
fi
done
}
#----------------------------Call It------------------------------------
Main_line
# EOF