https://github.com/hightail/express-mac/blob/express-mac-deploy/Express/updates.xml

express-deploy

#!/usr/local/bin/bash

function HELP {
  echo "Usage: $0 [ -a application [mac|windows] | -f file [Express.dmg|release-notes.html|updates.xml] | -r [1.0.2|1.0.1-RC16] ]"
  exit 1
}

if [ $# -lt 6 ]; then
        HELP
fi

# Sort out options
while getopts :a:f:r:h opt; do
  case $opt in
    a)
      # Application, either mac or windows
      APP=$OPTARG
      ;;
    f)
      # The name of your release asset file; i.e. Express.dmg|release-notes.html
      # Also the outfile name from wget
      FILE=$OPTARG
      ;;
    r)
      # tag/RC name; i.e. 1.0.0-RC10, 1.0.2 OR the word "latest"
      VERSION=$OPTARG
      ;;
    h)
      HELP
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      HELP
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      HELP
      ;;
  esac

done

shift $((OPTIND-1))

# Get the the github assts
TOKEN="[put-your-token-in-a-local-file-and-set-it-here]"
REPO="hightail/express-$APP"
GITHUB="https://api.github.com"
DIRECTORY=~/bin/express-mac-assets/$VERSION

# Make new release dir if it doe not exist
if [ ! -d "$DIRECTORY" ]; then
  mkdir "$DIRECTORY"
fi

cd "$DIRECTORY"

alias errcho='>&2 echo'

function auth_curl() {
  curl -H "Authorization: token $TOKEN" \
       -H "Accept: application/vnd.github.v3.raw" \
       $@
}

for FILE in Express.dmg release-notes.html updates.xml; do
  if [ "$VERSION" = "latest" ]; then
    # Github should return the latest release first.
    parser=".[0].assets | map(select(.name == \"$FILE\"))[0].id"
  else
    parser=". | map(select(.tag_name == \"$VERSION\"))[0].assets | map(select(.name == \"$FILE\"))[0].id"
  fi;

  asset_id=$(auth_curl -s $GITHUB/repos/$REPO/releases | jq "$parser")
  if [ "$asset_id" = "null" ]; then
    errcho "ERROR: version not found $VERSION"
    exit 1
  fi;

  wget -q --auth-no-challenge --header='Accept:application/octet-stream' \
    https://$TOKEN:@api.github.com/repos/$REPO/releases/assets/$asset_id \
  -O $FILE

done

# Sign the .dmg file
ruby ~/bin/sign_update.rb ~/bin/express-mac-assets/$VERSION/Express.dmg ~/bin/dsa_priv.pem > signature; \
ls -la ~/bin/express-mac-assets/$VERSION/Express.dmg |awk '{print $5}' >> signature

# Make changes to updates.xml for Publish date, version, signature and length

pubDATE=$(echo "$(date |cut -d' ' -f1-4) +0000")


# Create the new Object structure and upload files simultaneously
for i in $(ls); do
  aws s3api --region us-west-2 put-object --bucket static.hightail.com --key hightailexpress/1.0.2.18/$i --body $i;
done

# List the newly uploaded Objects
aws s3api --region us-west-2 list-objects --bucket static.hightail.com; \
--query 'Contents[].{Key: Key, Size: Size}' |grep hightailexpress/1.0.2.18

# Remove zero bytle file(s)
aws --region us-west-2 s3 ls s3://static.hightail.com/hightailexpress/1.0.2.18/; echo; \
aws --region us-west-2 s3 rm s3://static.hightail.com/hightailexpress/1.0.2.18/; echo; \
aws --region us-west-2 s3 ls s3://static.hightail.com/hightailexpress/1.0.2.18/; echo

# Copy Express.xml and updates.xml to root directory
for i in Express.dmg updates.xml; do
  aws s3api --region us-west-2 put-object --bucket static.hightail.com --key hightailexpress/$i --body $i;
done

# EOF


aws s3api --region us-west-2 copy-object --copy-source hightailexpress/windows/autoupdate.txt --key autoupdate_$(date +%Y-%m-%d).txt  --bucket static.hightail.com
