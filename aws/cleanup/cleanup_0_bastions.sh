source /Users/michal.wit/workspace/dev_util_scripts/awscli_env/vpc_functions/find_vpc_id_by_name_tag.sh

VPC_NAME="VpcWithTwoPublicSubnetsForEks-VPC"
VPC_ID=$(find_vpc_id_by_name_tag $VPC_NAME)

BASTIONS=$(
aws ec2 describe-instances --filters "Name=vpc-id,Values=$VPC_ID" "Name=tag:Name,Values=bastio*" \
  --query "Reservations[*].Instances[*].InstanceId" \
  --output text | xargs echo
)
echo "BASTIONS to delete: $BASTIONS"

aws ec2 terminate-instances --instance-ids $BASTIONS --output json | jq
