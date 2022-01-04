#!/bin/bash
# dev.digitalclone.com:
ENV='dev'
SLACK_CHANNEL='#release'
# default branch(s)
db_branch="master"
dm_branch="master"
cf_branch="master"
cl_branch="master"
#
while [ $# -gt 0 ]; do
  case "$1" in
    --version=*)
      version="${1#*=}"
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
      *)
      printf "* Error: Invalid argument.*\n"
      exit 1
    esac
  shift
done
#
cd work/
rm -rf keep-it-secret-keep-it-safe/
git clone git@github.com:[your-repo]/[your-repo].git
cd digitalclone-ui/
git checkout $ENV
git pull
if [ -z "$version" ]; then
  version=$(date +'%y-%m-%d-t%H%M%S')
fi
sudo docker tag dev.digitalclone-ui:latest dev.digitalclone-ui:$version
sudo docker build --no-cache --build-arg db_branch=${db_branch} --build-arg dm_branch=${dm_branch} \
                  --build-arg cf_branch=${cf_branch} --build-arg cl_branch=${cl_branch} \
                  -t dev.digitalclone-ui .
read -p "Image build complete. Continue? [Yn]: "
  if [[ $REPLY =~ ^[Nn]$ ]]; then
    printf "\nAborting\n\n"
    exit 1;
  fi
echo "Stopping the running container..."
sudo docker container stop $(sudo docker ps -q)
echo "Running the new container..."
sudo docker run -d --restart=unless-stopped -p 80:80 dev.digitalclone-ui:latest
echo "cleaning up the build..."
sudo docker system prune -f
sudo docker ps; echo
sudo docker system df; echo
sudo docker images; echo
HTTP=$(echo " HTTP Status: $(curl -Is --header 'www.digitalclone.com' 'http://dev.digitalclone.com/' |awk '/HTTP/ {print $2,$3,$4}')")
DATE=$(date +'%Y-%m-%d %H:%M:%S')
echo $HTTP
printf "\n **    End Of Build     **\n"
printf " ** $DATE **\n\n"
TEXT='
    "text": "New build for https://dev.digitalclone.com completed at: *'"${DATE}"'*",
    "attachments": [
        {
            "fallback": "dev.digitalclone.com",
            "pretext": "Environment: *'"${ENV}"'*",
            "title": "*Release Status*",
            "text": ":loading:'"${HTTP}"'",
            "color": "#36a64f",
            "mrkdwn_in": ["text", "pretext"]
        }
    ],
    "icon_emoji": ":sentient:"
'
curl -X POST --data-urlencode 'payload={"channel": "'${SLACK_CHANNEL}'", '"${TEXT}"'}' https://hooks.slack.com/services/ABABABABA/ABABABABA/ABABABABABABABABABABABABAB ; echo
echo
# EOE
# kill Docker and restart
# sudo systemctl stop docker && sudo systemctl start docker
# watch active logs:
  # sudo docker logs --follow $(sudo docker ps -q)
