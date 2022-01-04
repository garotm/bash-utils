#!/bin/bash
# dev.api.digitalclone.com:
ENV='dev'
SLACK_CHANNEL='#release'
# default branch(s)
api_branch="master"
#
while [ $# -gt 0 ]; do
  case "$1" in
    --version=*)
      version="${1#*=}"
      ;;
    --dc_api=*)
      api_branch="${1#*=}"
      ;;
      *)
      printf "* Error: Invalid argument.*\n"
      exit 1
    esac
  shift
done
#
if [ ! -d ~/work/keep-it-secret-keep-it-safe ]; then
  git clone git@github.com:sentientscience/blah-blah-blah.git
fi
cd ~/work/keep-it-secret-keep-it-safe/dev
git pull
cp ~/work/keep-it-secret-keep-it-safe/$ENV/config.json ~/work/dc-api/pyeai_api/config/
cd ~/work/dc-api
git checkout $api_branch
git pull
if [ -z "$version" ]; then
  version=$(date +'%y-%m-%d-t%H%M%S')
fi
sudo docker tag dev.digitalclone-api:latest dev.digitalclone-api:$version
sudo docker build --no-cache -t dev.digitalclone-api .
read -p "Image build complete. Continue? [Yn]: "
  if [[ $REPLY =~ ^[Nn]$ ]]; then
    printf "\nAborting\n\n"
    exit 1;
  fi
read -p "Do you want to perform a db migration? [Ny]: "
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Executing db migration for dcl-dev"
    cd ~/work/dc-api/sql/ && ./run_migrations.sh && cd -
    grep -A 25 'Migrating' ~/current-migration-errors.logcurrent-migration-errors.log
  else
    echo "Not executing db migration for dcl-dev"
  fi
read -p "Database phase complete. Continue? [Yn]: "
  if [[ $REPLY =~ ^[Nn]$ ]]; then
    printf "\nAborting\n\n"
    exit 1;
  fi
echo "Stopping the running container..."
sudo docker container stop $(sudo docker ps -q)
echo "Running the new container..."
sudo docker run -d --restart=unless-stopped -p 80:6543 dev.digitalclone-api:latest
echo "cleaning up the build..."
sudo docker system prune -f
sudo docker ps; echo
sudo docker system df; echo
sudo docker images; echo
HTTP=$(echo " HTTP Status: $(curl -Is --header 'www.digitalclone.com' 'http://dev.api.digitalclone.com/version/' |awk '/HTTP/ {print $2,$3,$4}')")
DATE=$(date +'%Y-%m-%d %H:%M:%S')
echo $HTTP
printf "\n **    End Of Build     **\n"
printf " ** $DATE **\n\n"
TEXT='
    "text": "New build for https://dev.api.digitalclone.com/version/ completed at: *'"${DATE}"'*",
    "attachments": [
        {
            "fallback": "dev.api.digitalclone.com",
            "pretext": "Environment: *'"${ENV}"'*",
            "title": "*Release Status*",
            "text": ":loading:'"${HTTP}"'",
            "color": "#36a64f",
            "mrkdwn_in": ["text", "pretext"]
        }
    ],
    "icon_emoji": ":sentient:"
'
curl -X POST --data-urlencode 'payload={"channel": "'${SLACK_CHANNEL}'", '"${TEXT}"'}' https://hooks.slack.com/services/ABABABABA/ABABABABA/ABABABABABABABABABABABAB ; echo
echo
# EOE
# kill Docker and restart
# sudo systemctl stop docker && sudo systemctl start docker
# watch active logs:
  # sudo docker logs --follow $(sudo docker ps -q)
