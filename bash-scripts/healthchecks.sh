#!/usr/local/bin/bash

# AWS elb's
elbns="spaces-prod-api spaces-prod-billing-us spaces-prod-billing-edge spaces-prod-content spaces-prod-hfs-ed spaces-prod-insight spaces-prod-link spaces-prod-storage spaces-prod-user spaces-prod-video"

# Get pretty healthcheck from 1 instance in each app in each region
function AWS {
  printf '\n\e[1;31m%-6s\e[m\n' "----------------------------------"
  printf '\e[1;34m%-6s\e[m\n' "region is: $region"
  printf '\e[1;34m%-6s\e[m\n' "  elbn is: $elbn"
  printf '\e[1;34m%-6s\e[m\n' "  port is: $PORT"
  printf '\e[1;31m%-6s\e[m\n' "----------------------------------"
  ssh $(aws --region $region ec2 describe-instances --query 'Reservations[].Instances[].[PrivateIpAddress,Tags[?Key==`Name`]| [0].Value]' --output text |grep $elbn |cut -f1 |head -1) "hostname; curl -s http://localhost:$PORT/healthcheck?pretty=true |tr -d [:punct:]"
  echo
}

# Loop through the apps (elbs), set the port, region and run the AWS function
for elbn in $elbns; do
  if [[ "$elbn" = "spaces-prod-api" || "$elbn" = "spaces-prod-billing-us" || "$elbn" = "spaces-prod-hfs-ed" ]]; then
    PORT=8081
    region="us-west-2"
    AWS
  elif [ "$elbn" = "billing-edge" ]; then
    PORT=8101
    region="us-west-2"
    AWS
  elif [ "$elbn" = "spaces-prod-content" ]; then
    PORT=8111
    regions="us-west-2 us-east-1 eu-west-1 ap-southeast-2"
    for region in $regions; do
      AWS
    done
  elif [ "$elbn" = "spaces-prod-insight" ]; then
    PORT=8071
    region="us-west-2"
    AWS
  elif [ "$elbn" = "spaces-prod-link" ]; then
    PORT=8121
    region="us-west-2"
    AWS
  elif [ "$elbn" = "spaces-prod-storage" ]; then
    PORT=8131
    region="us-west-2"
    AWS
  elif [ "$elbn" = "spaces-prod-user" ]; then
    PORT=8141
    region="us-west-2"
    AWS
  elif [ "$elbn" = "spaces-prod-video" ]; then
    PORT=8091
    region="us-west-2"
    AWS
  fi
done

printf '\n\e[1;31m%-6s\e[m\n\n' "$(date)"

# EOF
