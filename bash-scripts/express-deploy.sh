#!/usr/local/bin/bash

# PREREQUISITES
# curl, wget, jq, aws, ruby

# Default help
function HELP {
  echo "Usage: $0 [ -a [mac|windows|plugins] -r [1.0.2.17|1.0.1-RC16] -t [(test) OPTIONAL] ]"
  exit 1
}

# Ensure at least 4 args are called (including flags)
if [ $# -lt 4 ]; then
        HELP
fi

# Sort out options
while getopts :a:r:ht opt; do
  case $opt in
    a)
      # Ensure the flag is present (double check)
      if [ $OPTARG -eq 0 ]; then
	echo "You must provide an arg for -a flag"
	HELP
      fi
      # Application, either mac, windows or plugins
      APP=$OPTARG
      ;;
    r)
      # Ensure the flag is present (double check)
      if [ $OPTARG -eq 0 ]; then
        echo "You must provide an arg for -r flag"
        HELP
      fi
      # tag/RC name; i.e. 1.0.0-RC10, 1.0.2.17 OR the word "latest"
      VERSION=$OPTARG
    t)
      # Use in test mode, or pre-prod deploy for QA; optional
      TEST
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

function GIT_H() {
  # Get the the github assts
  TOKEN="[put-your-token-in-a-local-file-and-set-it-here]"
  REPO="hightail/express-$APP"
  GITHUB="https://api.github.com"
  DIRECTORY=~/bin/express-$APP-assets/$VERSION

  # Make new release dir if it does not exist
  if [ ! -d "$DIRECTORY" ]; then
    mkdir -pv "$DIRECTORY"
  fi

  cd "$DIRECTORY"

  alias errcho='>&2 echo'

  function auth_curl() {
    curl -H "Authorization: token $TOKEN" \
         -H "Accept: application/vnd.github.v3.raw" \
         $@
  }

  for FILE in $FILES; do
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
}

function TEST {
  echo "This doesn't work yet."
}

function VALIDATION {
  read -p "Are you ready to proceed? [Yn]: " -n 1 -r
  if [[ $REPLY =~ ^[Nn]$ ]]; then
    printf "\nAborting\n\n"
    exit 1;
  fi
}

if [ "$APP" = "mac" ]; then
  FILES="Express.dmg release-notes.html updates.xml"

  # Call the function for gist asset access
  GIT_H

  # Sign the .dmg file
  ruby ~/bin/sign_update.rb ~/bin/express-mac-assets/$VERSION/Express.dmg ~/bin/dsa_priv.pem > signature
  ls -la ~/bin/express-mac-assets/$VERSION/Express.dmg |awk '{print $5}' >> signature
  echo "$(date |cut -d' ' -f1-4) +0000" >> signature
  printf "\nCopy and paste the following to a scratchpad to be used in the next step.\n\n"
  cat signature
  printf "\n\nThis information is in $(pwd)/signature if you didn't catch it in time...\n"
  printf "Complete instruction can be found here:\n"
  printf "https://github.com/hightail/express-mac/blob/master/README.md\n\n"
  sleep 5
  echo

  # Make changes to updates.xml for Publish date, version, signature and length
  vi updates.xml

  # Create the new Object structure and upload files simultaneously
  for i in $(ls); do
    aws s3api --region us-west-2 put-object --bucket static.hightail.com --key hightailexpress/$VERSION/$i --body $i;
  done

  # Remove zero bytle file(s)
  aws --region us-west-2 s3 rm s3://static.hightail.com/hightailexpress/$VERSION/

  # Copy Express.dmg and updates.xml to root directory
  for i in Express.dmg updates.xml; do
    aws s3api --region us-west-2 put-object --bucket static.hightail.com --key hightailexpress/$i --body $i;
  done

  # List the newly updated folder Objects
  printf "Folder $VERSION contents:\n"
  aws --region us-west-2 s3 ls s3://static.hightail.com/hightailexpress/$VERSION/
  date +'%Y-%m-%d %H:%M:%S'

  # List the newly uploaded root Objects
  printf "\nRoot Folder Contents:\n\n"
  aws --region us-west-2 s3 ls s3://static.hightail.com/hightailexpress/ |egrep 'Express.dmg|updates.xml'
  date +'%Y-%m-%d %H:%M:%S'

elif [ "$APP" = "windows" ]; then
  FILES="Express-$VERSION.msi autoupdate.txt"

  # Call the function for gist asset access
  GIT_H

  # Copy Express-$VERSION.msi, Express.msi (same as Express-$VERSION.msi with universal name) and autoupdate.txt to root directory (post-rename of existing autoupdate.txt)
  aws s3api --region us-west-2 put-object --bucket static.hightail.com --key hightailexpress/Express-$VERSION.msi --body Express-$VERSION.msi
  aws s3api --region us-west-2 put-object --bucket static.hightail.com --key hightailexpress/Express-$VERSION.msi --body Express.msi
  aws --region us-west-2 s3 cp s3://static.hightail.com/hightailexpress/windows/autoupdate.txt \
   s3://static.hightail.com/hightailexpress/windows/autoupdate_$(date +%Y-%m-%d).txt
  aws s3api --region us-west-2 put-object --bucket static.hightail.com --key hightailexpress/$APP/autoupdate.txt --body autoupdate.txt

  # List the newly uploaded Objects
  printf "\nRoot Folder Contents:\n"
  aws --region us-west-2 s3 ls s3://static.hightail.com/hightailexpress/Express.msi
  aws --region us-west-2 s3 ls s3://static.hightail.com/hightailexpress/Express-$VERSION.msi
  aws --region us-west-2 s3 ls s3://static.hightail.com/hightailexpress/windows/autoupdate.txt
  date +'%Y-%m-%d %H:%M:%S'

elif [ "APP" = "plugins" ]; then
  # Need to interactively grab the file we are looking for at this point as the
  # naming convention for this aspect has not yet been solidified.
  # read -p 'Enter the .msi file name: ' NEW_MSI
  FILES="HfO-$VERSION.msi"

  # Grabbing assets from GIT

  echo "Fetching gist assets for $FILES"

  VALIDATION

  # Call the function for gist asset access
  GIT_H

  # List file in CWD
  echo "This is what was fetched:"
  pwd
  ls -l

  VALIDATION

  # Copy newly downloaded file to the correctly named file for upload to S3
  echo "Renaming asset(s):"
  cp $FILES HightailForOutlook.msi
  ls -l

  VALIDATION
  # Initial Listing
  echo "This is what is currently in the AWS S3 'plugins' Object:"
  aws --region us-west-2 s3 ls s3://static.hightail.com/plugins/ |grep HightailForOutlook.msi

  VALIDATION
  # Rename the existing file on S3
  echo "Renaming the new local asset:"
  aws --region us-west-2 s3 cp s3://static.hightail.com/plugins/HightailForOutlook.msi s3://static.hightail.com/plugins/HightailForOutlook_$(date +%Y-%m-%d).msi
  ls -l

  VALIDATION
  # Push the new file up to S3
  echo "Push the renamed asset to S3:"
  aws s3api --region us-west-2 put-object --bucket static.hightail.com --key plugins/HightailForOutlook.msi --body HightailForOutlook.msi
  # List both new and renamed file(s)
  aws --region us-west-2 s3 ls s3://static.hightail.com/plugins/ |egrep 'HightailForOutlook.msi|HightailForOutlook_'
  date +'%Y-%m-%d %H:%M:%S'

  VALIDATION
else
  HELP
  exit 1
fi
# Invalidate the Object (folder)
echo "Invalidating the S3 Object to enact change(s):"
VALIDATION
if [ "APP" = "plugins" ]; then
  aws cloudfront create-invalidation --distribution-id E2SIE050IE3E3V \
    --paths /plugins/*
else
  aws cloudfront create-invalidation --distribution-id E2SIE050IE3E3V \
    --paths /hightailexpress/*
# EOF
