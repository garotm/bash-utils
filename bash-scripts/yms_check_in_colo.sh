#!/usr/local/bin/bash
#:
if [ $# -lt 1 ]; then
        echo "USAGE: $0 domain endpoint(s)"
        exit -1;
fi
#:
#: VARS
#:
ARGS=$@;
HNAME=$(uname -n |grep -o '[.]..[0-9]' |cut -d. -f2)
#:
#: Conditional
#:
for i in $ARGS; do
if [[ $(dig -xv $i |grep CNAME -A2 |awk '/[0-9].[0-9].[0-9].[0-9]/ {print $5}' | xargs nslookup |awk '/name/ {print $4}' |grep -o '[.]..[0-9]' |cut -d. -f2) = "$HNAME" ]]; then
printf "{
   \"application\":\"yms_check_in_colo\",
   \"dimensions\":{
      \"endpoint\":\"$i\",
      \"ep_colo\":\"$HNAME\"
   }
}

{
   \"status_code\":0,
   \"application\":\"yms_check_in_colo\",
   \"status_msg\":\"Resolving same colo: $i\"
}\n"
else
printf "{
   \"application\":\"yms_check_in_colo\",
   \"dimensions\":{
      \"endpoint\":\"$i\",
      \"ep_colo\":\"$HNAME\"
   }
}

{
   \"status_code\":1,
   \"application\":\"yms_check_in_colo\",
   \"status_msg\":\"Resolving cross colo: $i\"
}\n"
fi;
done
exit 0;
#: EOF


if [ $# -lt 1 ]; then
        echo "USAGE: $0 domain endpoint(s)"
        exit -1;
fi
#:
#: VARS
#:
ARGS=$@;
HNAME=$(uname -n |grep -o '[.]..[0-9]' |cut -d. -f2)
#:
#: Conditional
#:
for i in $ARGS; do
if [[ $(dig -xv $i |grep CNAME -A2 |awk '/[0-9].[0-9].[0-9].[0-9]/ {print $5}' |head -1 |xargs nslookup |awk '/name =/ {print $4}' |grep -o '[.]..[0-9]' |cut -d. -f2) = "$HNAME" ]]; then
printf "{
   \"application\":\"yms_check_in_colo\",
   \"dimensions\":{
      \"endpoint\":\"$i\",
      \"ep_colo\":\"$HNAME\"
   }
}

{
   \"status_code\":0,
   \"application\":\"yms_check_in_colo\",
   \"status_msg\":\"Resolving same colo: $i => $(dig -xv $i |grep CNAME -A2 |awk '/[0-9].[0-9].[0-9].[0-9]/ {print $5}' |head -1 |xargs nslookup |awk '/name =/ {print $4}' |grep -o '[.]..[0-9]' |cut -d. -f2)\"
}\n"
else
printf "{
   \"application\":\"yms_check_in_colo\",
   \"dimensions\":{
      \"endpoint\":\"$i\",
      \"ep_colo\":\"$HNAME\"
   }
}

{
   \"status_code\":1,
   \"application\":\"yms_check_in_colo\",
   \"status_msg\":\"Resolving cross colo: $i => $(dig -xv $i |grep CNAME -A2 |awk '/[0-9].[0-9].[0-9].[0-9]/ {print $5}' |head -1 |xargs nslookup |awk '/name =/ {print $4}' |grep -o '[.]..[0-9]' |cut -d. -f2)\"
}\n"
fi;
done
exit 0;
#: EOF