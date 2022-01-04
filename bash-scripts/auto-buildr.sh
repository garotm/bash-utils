#!/bin/bash
# *.digitalclone.com:
SLACK_CHANNEL='#release'
# default branch(s)
# UI
db_branch="master"
dm_branch="master"
cf_branch="master"
cl_branch="master"
# API
api_branch="master"
# V2
v2_branch="master"
# database migration
db_migrate="yes"
# default environment
env="dev"
while [ $# -gt 0 ]; do
  case "$1" in
    --tag=*)
      tag="${1#*=}"
      ;;
    --dashboard=*)
      db_branch="${1#*=}"
      ;;
    --data_management=*)
      dm_branch="${1#*=}"
       ;;
    --config_library=*)
      cl_branch="${1#*=}"
      ;;
    --content_factory=*)
      cf_branch="${1#*=}"
      ;;
    --dc_api=*)
      api_branch="${1#*=}"
      ;;
    --dcl_legacy=*)
      v2_branch="${1#*=}"
      ;;
    --module=*) # api|ui|v2
      module="${1#*=}"
      ;;
    --env=*) # demo|dev|qa|prod
      env="${1#*=}"
      ;;
    --db_migrate=*) # yes|no
      db_migrate="${1#*=}"
      ;;  
      *)
      printf "* Error: Invalid argument.*\n"
      exit 1
    esac
  shift
done
#
function post_build() {
  echo "cleaning up the build..."
  sudo docker system prune -f
  sudo docker ps; echo
  sudo docker system df; echo
  sudo docker images; echo

  if [ "$env" = "prod" ]; then
    if [ "$module" = "ui" ]; then
      HOST='digitalclone.com'
    elif [[ "$module" = "api" || "$module" = "v2" ]]; then
      HOST='$module.digitalclone.com'
    fi
  elif [[ "$env" = "qa" || "$env" = "v2" ]]; then
      HOST='$env.$module.digitalclone.com'
  fi
  HTTP=$(echo " HTTP Status: $(curl -Is --header 'www.digitalclone.com' 'http://$HOST/tag/' |awk '/HTTP/ {print $2,$3,$4}')")
  DATE=$(date +'%Y-%m-%d %H:%M:%S')
  echo $HTTP
  printf "\n **    End Of Build     **\n"
  printf " ** $DATE **\n\n"
  TEXT='
      "text": "New build for http://'"${HOST}"'/ completed at: *'"${DATE}"'*",
      "attachments": [
           {
              "fallback": "'"${HOST}"'",
              "pretext": "Environment: *'"${env}"'*",
              "title": "*Release Status*",
              "text": ":loading:'"${HTTP}"'",
              "color": "#36a64f",
              "mrkdwn_in": ["text", "pretext"]
           }
       ],
       "icon_emoji": ":sentient:"
'
curl -X POST --data-urlencode 'payload={"channel": "'${SLACK_CHANNEL}'", '"${TEXT}"'}' https://hooks.slack.com/services/ABABABABA/ABABABABA/ABABABABABABABABABABABABA ; echo
echo
}
# safe-guards
if [ ! -d ~/work/keep-it-secret-keep-it-safe ]; then
  cd ~/work
  git clone git@github.com:[grab-your-repo]/[grab-your-repo].git
fi
if [ -z "$tag" ]; then
    tag=$(date +'%y-%m-%d-t%H%M%S')
fi
# dc-api
if [ "$module" = "api" ]; then
  cd ~/work/keep-it-secret-keep-it-safe/$env
  git pull
  cp ~/work/keep-it-secret-keep-it-safe/$env/config.json ~/work/dc-api/pyeai_api/config/
  if [ ! -d ~/work/dc-api ]; then
    cd ~/work
    git clone git@github.com:sentientscience/dc-api.git
  fi  
  cd ~/work/dc-api
  git checkout $api_branch
  git pull
  docker tag $env.digitalclone-api:latest $env.digitalclone-api:$tag
  sudo docker build --no-cache -t $env.digitalclone-api .
  if [ "$db_migrate" = "yes" ]; then
    echo "Executing db migration for dcl-$env"
    cd ~/work/dc-api/sql/ && ./run_migrations.sh && cd -
    grep -A 25 'Migrating' ~/current-migration-errors.logcurrent-migration-errors.log
  else
    echo "Not executing db migration for dcl-$env"
  fi  
  echo "Stopping the running container..."
  sudo docker container stop $(sudo docker ps -q)
  echo "Running the new container..."
  sudo docker run -d --restart=unless-stopped -p 80:6543 $env.digitalclone-api:latest
  post_build
# digitalclone-ui
elif [ "$module" = "ui" ]; then
  cd work/
  rm -rf keep-it-secret-keep-it-safe/
  git clone git@github.com:sentientscience/keep-it-secret-keep-it-safe.git
  cd digitalclone-ui/
  git checkout $env
  git pull
  sudo docker tag $env.digitalclone-ui:latest $env.digitalclone-ui:$tag
  sudo docker build --no-cache --build-arg db_branch=${db_branch} --build-arg dm_branch=${dm_branch} \
                    --build-arg cf_branch=${cf_branch} --build-arg cl_branch=${cl_branch} \
                    -t $env.digitalclone-ui .
  echo "Stopping the running container..."
  sudo docker container stop $(sudo docker ps -q)
  echo "Running the new container..."
  sudo docker run -d --restart=unless-stopped -p 80:80 $env.digitalclone-ui:latest
  post_build
# dcl-legacy
elif [[ "$module" = "v2" || "$module" = "legacy" ]]; then
  cd ~/work/keep-it-secret-keep-it-safe
  git pull
  if [ ! -d ~/work/dcl-legacy ]; then
    cd ~/work
    git clone git@github.com:sentientscience/dcl-legacy.git
  fi 
  cd ~/work/dcl-legacy/
  git checkout $v2_branch
  git pull
  sudo docker tag $env.digitalclone-v2:latest $env.digitalclone-v2:$version
  cp ~/work/keep-it-secret-keep-it-safe/$env/consul_db_sage.json ~/work/dcl-legacy/DCSoftware/
  sudo docker build --no-cache -t $env.digitalclone-v2 .
  echo "Stopping the running container..."
  sudo docker container stop $(sudo docker ps -q)
  echo "Running the new container..."
  sudo docker run -d --restart=unless-stopped -p 80:80 $env.digitalclone-v2:latest
  post_build
else
  printf "* Error: Argument missing: [ --module=null ] .*\n"
  exit 1
fi
