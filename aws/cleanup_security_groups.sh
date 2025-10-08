source /Users/michal.wit/workspace/dev_util_scripts/awscli_env/ec2_functions/find_security_group_id_by_name_tag.sh
SG_NAME="witm-training-sg-ssh-http-icmp"
SG_ID=$(find_security_group_id_by_name_tag $SG_NAME)
aws ec2 delete-security-group --group-id $SG_ID --output json | jq
