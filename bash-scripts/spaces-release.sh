spaces-release.sh

#!/usr/local/bin/bash

# Get Environment list

ENV_LIST=$(knife environment list |egrep 'prod|spaces-hightail')

# Get each environments app list

APPS=$(knife environment compare stage prod spaces-hightail |awk '{print $1}' |sed '/^\s*$/d' |sort)

#

function Stage_Compare() {
        knife environment compare stage $1 |egrep -v 'prod|spaces-hightail|stage' |sed '/^\s*$/d'
}

# Banner

echo "
    ___ ___  _   ___ ___ ___   ___ ___ _    ___   _   ___ ___
   / __| _ \/_\ / __| __/ __| | _ \ __| |  | __| /_\ / __| __|
   \__ \  _/ _ \ (__| _|\__ \ |   / _|| |__| _| / _ \\__ \ _|
   |___/_|/_/ \_\___|___|___/ |_|_\___|____|___/_/ \_\___/___|
               Hightail Spaces Production Release
                   $(date)
"
# Simple formatting

BOLD=$(tput bold)
NORM=$(tput sgr0)

# Raw environemtn output

printf '\n\e[1;33m%-6s\e[m\n' "Environmental Overview:"
echo "--------------------------------------------------"
knife environment compare stage prod spaces-hightail

# Compare Stage and Prod

for e in $ENV_LIST; do
        c=$(echo "${e:0:1}" | tr a-z A-Z)${e:1}; echo -n "Proposed $c Environment Changes"
        printf '\n\n\e[1;33m%-6s\e[m\n' "Application:            Stage:    $c:"
        echo "--------------------------------------------------"
        for i in $APPS; do
		        STAGE_FULL=$(Stage_Compare $e |grep $i |tr -d '=' |awk '{print $2}')
		        STAGE=$(echo $STAGE_FULL |tr -d [:punct:])
		        OTHER_FULL=$(Stage_Compare $e |grep $i |tr -d '=' |awk '{print $3}')
		        OTHER=$(echo $OTHER_FULL |tr -d [:punct:])
		          if [[ $STAGE -ne $OTHER ]]; then
			             if [[ "$STAGE" != "latest" && "$OTHER" != "latest" ]]; then
				                 # Set array's of the actual apps that are going to be deployed
				                 if [[ "$e" == "prod" ]]; then
					                      declare -a PROD_APPS+=$(Stage_Compare $e |grep $i |awk '{print $1" "}')
					                      PROD_APP=("${PROD_APPS[*]}")
					                      echo "${BOLD}$(Stage_Compare $e |grep $i |tr '=' ' ')${NORM}"
					                      echo "----------------------------------------"
                                echo "nc compare me hightail/${PROD_APPS[$i]} $OTHER_FULL $STAGE_FULL"
					                      if [[ PROD_APPS[$i] == "webapp" ]]; then
						                            echo "nc compare me hightail/webapp_ea $OTHER_FULL $STAGE_FULL-ea"
					                      fi
					                      unset "PROD_APPS[$i]"
				                else
					                     declare -a SPACES_APPS+=$(Stage_Compare $e |grep $i |awk '{print $1" "}')
					                     SPACES_APP=("${SPACES_APPS[*]}")
					                     echo "${BOLD}$(Stage_Compare $e |grep $i |tr '=' ' ')${NORM}"
					                     echo "----------------------------------------"
                               echo "nc compare me hightail/${SPACES_APPS[$i]} $OTHER_FULL $STAGE_FULL"
					                     if [[ SPACES_APPS[$i] == "webapp" ]]; then
                                        echo "nc compare me hightail/webapp_ea $OTHER_FULL $STAGE_FULL-ea"
					                     fi
                               unset "PROD_APPS[$i]"
					                     unset "SPACES_APPS[$i]"
				                fi
				                printf "\nnc set cookbook $i $STAGE_FULL in $e\n"
                        printf "nc deploy $i $STAGE_FULL to $e weekly release\n\n"
			             fi
		          fi
        done
        printf "   \n################    \n\n"
done

# PURGE FASTLY:

printf '\n\e[1;33m%-6s\e[m\n' "Purge fastly following the webapp deployment completion @ the following URL:"
printf "https://app.fgastly.com/#analytics/3RTS48g7AUcqSSw5P65x1w\n\n"

# GIT merges to be done

printf '\n\e[1;33m%-6s\e[m\n' "GIT Merges:"
echo "--------------------------------------------------"

# The app name(s) in git do not match the app name(s) in the actual server env :(

function REPOS() {
        echo "cd ~/bin/chef-spaces-aws/hightail_private_repos/$j"
        echo "git checkout master"
        echo "git pull"
        echo "git merge $(Stage_Compare stage |grep $i |tr -d '=' |awk '{print $2}')"
        echo "git push"
        echo "   ---"
}
ALL_APPS="$PROD_APPS  $SPACES_APPS"

for i in $PROD_APP $SPACES_APP; do
        case "$i" in
          api_server)
            j=api
            REPOS
            ;;
		      billing_server)
			      j=billing
			      REPOS
			      ;;
		      billing_edge)
			      j=billing-edge
			      REPOS
			      ;;
          content_api)
            j=content-api
            REPOS
            ;;
          htbot)
            j=nc
            REPOS
            ;;
		      html_email)
			      j=html-email
			      REPOS
			      ;;
          insight_service)
            j=insight-service
            REPOS
            ;;
          notification_service)
            j=notification-service
            REPOS
            ;;
		      prerender)
			      j=prerender-wilson
			      REPOS
			      ;;
		      video_preview_server)
			      j=preview-video
			      REPOS
			      ;;
          webapp|webapp_ea)
            j=web
            REPOS
            ;;
          web_docs)
            j=web-docs
            REPOS
            ;;
          websupport)
            j=web-support-tool
            REPOS
            ;;
          *)
            j=$i
            REPOS
        esac
done

echo "   --- ${BOLD}DONE${NORM}  ---   "
echo
exit