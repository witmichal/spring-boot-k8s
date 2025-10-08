source /Users/michal.wit/workspace/dev_util_scripts/awscli_env/ec2_functions/find_security_group_id_by_name_tag.sh
source /Users/michal.wit/workspace/dev_util_scripts/awscli_env/vpc_functions/find_vpc_id_by_name_tag.sh

SG_NAME="witm-training-sg-ssh-http-icmp"
SG_ID=$(find_security_group_id_by_name_tag $SG_NAME)
echo "SG_ID: $SG_ID"
aws ec2 delete-security-group --group-id $SG_ID --output json | jq

#### remove non-default SGs from the VPC
VPC_NAME="VpcWithTwoPublicSubnetsForEks-VPC"
VPC_ID=$(find_vpc_id_by_name_tag $VPC_NAME)

SG_NOT_DEFAULT=$(
  aws ec2 get-security-groups-for-vpc --vpc-id $VPC_ID --output json \
    | jq -r '.SecurityGroupForVpcs | map({gid:.GroupId, gname:.GroupName}) | map(select( .gname | contains("default") | not)) | map(.gid) | join("\n")'
)
echo "$SG_NOT_DEFAULT" | xargs -I {} echo "SG to delete: {}"
echo "$SG_NOT_DEFAULT" | xargs -I {} aws ec2 delete-security-group --group-id {} --output json | jq
