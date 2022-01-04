#!/bin/bash
# dev.v2.digitalclone.com:
ENV='dev'
SLACK_CHANNEL='#release'
# default branch(s)
v2_branch="master"
#
while [ $# -gt 0 ]; do
  case "$1" in
    --version=*)
      version="${1#*=}"
      ;;
    --dcl_legacy=*)
      v2_branch="${1#*=}"
      ;;
      *)
      printf "* Error: Invalid argument.*\n"
      exit 1
    esac
  shift
done
#
if [ ! -d ~/work/keep-it-secret-keep-it-safe ]; then
  cd ~/work
  git clone git@github.com:[your-repo]/[your-repo].git
fi
cd ~/work/keep-it-secret-keep-it-safe
git pull
cd ~/work/dcl-legacy/
git checkout $v2_branch
git pull
if [ -z "$version" ]; then
  version=$(date +'%y-%m-%d-t%H%M%S')
fi
sudo docker tag dev.digitalclone-v2:latest dev.digitalclone-v2:$version
cp ~/work/keep-it-secret-keep-it-safe/$ENV/consul_db_sage.json ~/work/dcl-legacy/DCSoftware/
sudo docker build --no-cache -t dev.digitalclone-v2 .
read -p "Image build complete. Continue? [Yn]: "
  if [[ $REPLY =~ ^[Nn]$ ]]; then
    printf "\nAborting\n\n"
    exit 1;
  fi
echo "Stopping the running container..."
sudo docker container stop $(sudo docker ps -q)
echo "Running the new container..."
sudo docker run -d --restart=unless-stopped -p 80:80 dev.digitalclone-v2:latest
echo "cleaning up the build..."
sudo docker system prune -f
sudo docker ps; echo
sudo docker system df; echo
sudo docker images; echo
HTTP=$(echo " HTTP Status: $(curl -Is --header 'www.digitalclone.com' 'http://dev.v2.digitalclone.com/' |awk '/HTTP/ {print $2,$3,$4}')")
DATE=$(date +'%Y-%m-%d %H:%M:%S')
echo $HTTP
printf "\n **    End Of Build     **\n"
printf " ** $DATE **\n\n"
TEXT='
    "text": "New build for https://dev.v2.digitalclone.com completed at: *'"${DATE}"'*",
    "attachments": [
        {
            "fallback": "dev.v2.digitalclone.com",
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
