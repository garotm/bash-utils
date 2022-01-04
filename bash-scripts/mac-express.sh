mac-express.sh

function HELP {
  echo "Usage: $0 [ -a application [mac|windows] | -f file [Express.dmg|release-notes.html] | -r [1.0.2.17] ]"
  exit 1
}

if [ $# -lt 3 ]; then
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

# Get the the github assts
TOKEN=$(cat ~/.git/.express-mac-asset)
REPO="hightail/express-$APP"
GITHUB="https://api.github.com"
# APP=$1
# VERSION=$2        # tag name; i.e. 1.0.0-RC10 OR the word "latest"
# FILE=$3           # the name of your release asset file; i.e. Express.dmg|release-notes.html also to to be outfile name from wget

# Make new release dir
cd ~/bin/express-mac-assets
mkdir $VERSION
cd $VERSION

alias errcho='>&2 echo'

function auth_curl() {
  curl -H "Authorization: token $TOKEN" \
       -H "Accept: application/vnd.github.v3.raw" \
       $@
}

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

shift $((OPTIND-1))

# List the newly uploaded Objects
aws s3api --region us-west-2 list-objects --bucket static.hightail.com; \
--query 'Contents[].{Key: Key, Size: Size}' |grep hightailexpress/1.0.2.18

# Make changes to updates.xml for Publish date, version, signature and length

# Create the new Object structure and upload files simultaneously
for i in $(ls); do
  aws s3api --region us-west-2 put-object --bucket static.hightail.com --key hightailexpress/1.0.2.18/$i --body $i;
done

# Remove zero bytle file(s)
aws --region us-west-2 s3 ls s3://static.hightail.com/hightailexpress/1.0.2.18/; echo; \
aws --region us-west-2 s3 rm s3://static.hightail.com/hightailexpress/1.0.2.18/; echo;  \
aws --region us-west-2 s3 ls s3://static.hightail.com/hightailexpress/1.0.2.18/; echo

# Copy Express.xml and updates.xml to root directory
for i in Express.dmg updates.xml; do
  aws s3api --region us-west-2 put-object --bucket static.hightail.com --key hightailexpress/$i --body $i;
done

# EOF