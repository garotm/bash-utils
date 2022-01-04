#!/bin/bash

function HELP {
  echo "Usage: $0 [ -a account_id | -e user_email | -u user_id ]"
  exit 1
}

if [ $# -lt 1 ]; then
        HELP
fi

while getopts :a:e:u:h opt; do
  case $opt in
    a)
      accounts=$(mysql -uysi -pysi -e 'SET @account_id='$OPTARG'; SELECT user_id FROM YSIUSER.users_accounts WHERE account_id = @account_id AND status NOT LIKE "LOC" ORDER BY status;' YSIUSER |tr -d [:alpha:]_ |sed -e '$!s/$/,/' -e '1s/^.//');
      ;;
    e)
      email_id=$(mysql -uysi -pysi -e 'SET @email_id="'$OPTARG'"; SELECT user_id FROM YSIUSER.ysi_user_info WHERE email_id = '@email_id';' YSIUSER |tr -d [:cntrl:][:alpha:]_);
      id=$(mysql -uysi -pysi -e 'SET @user_id='$email_id'; SELECT account_id FROM YSIUSER.users_accounts WHERE user_id = @user_id;' YSIUSER |tr -d [:cntrl:][:alpha:]_);
      accounts=$(mysql -uysi -pysi -e 'SET @account_id='$id'; SELECT user_id FROM YSIUSER.users_accounts WHERE account_id = @account_id AND status NOT LIKE "LOC" ORDER BY status;' YSIUSER |tr -d [:alpha:]_ |sed -e '$!s/$/,/' -e '1s/^.//');
      ;;
    u)
      id=$(mysql -uysi -pysi -e 'SET @user_id='$OPTARG'; SELECT account_id FROM YSIUSER.users_accounts WHERE user_id = @user_id;' YSIUSER |tr -d [:cntrl:][:alpha:]_);
      accounts=$(mysql -uysi -pysi -e 'SET @account_id='$id'; SELECT user_id FROM YSIUSER.users_accounts WHERE account_id = @account_id AND status NOT LIKE "LOC" ORDER BY status;' YSIUSER |tr -d [:alpha:]_ |sed -e '$!s/$/,/' -e '1s/^.//');
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
  printf "\nUPDATE ysi_user_info SET acct_status='LOC',date_modified=now() where user_id in ($accounts);\n\n"
  printf "UPDATE users_accounts SET status='LOC',updated_on=now() where user_id in ($accounts);\n\n"
done

shift $((OPTIND-1))

#EOF
