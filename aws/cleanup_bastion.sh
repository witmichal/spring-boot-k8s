source /Users/michal.wit/workspace/dev_util_scripts/awscli_env/ec2_functions/find_ec2_instance_by_name.sh

ID=$(find_ec2_instance_by_name bastion)
aws ec2 terminate-instances --instance-ids $ID --output json | jq
