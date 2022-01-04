#!/bin/bash
# Run PhishMe terraform plan extraneous 
#
terraform plan -out=PhishMe_plan
terraform graph | dot -Tpng > PhishMe_plan.png
terraform apply "PhishMe_plan"
for i in alb ec2 sg vpc; do 
	echo $i 
	terraforming $i
	echo 
done
# EOF
