source /Users/michal.wit/workspace/dev_util_scripts/awscli_env/ec2_functions/run_instance_with_key_pair.sh
source /Users/michal.wit/workspace/dev_util_scripts/awscli_env/ec2_functions/find_ec2_running_instance_by_name.sh
source /Users/michal.wit/workspace/dev_util_scripts/awscli_env/ec2_functions/find_security_group_id_by_name_tag.sh
source /Users/michal.wit/workspace/dev_util_scripts/awscli_env/ec2_functions/describe_running_instance.sh

SECURITY_GROUP_NAME="witm-training-sg-ssh-http-icmp"
SG_ID=$(find_security_group_id_by_name_tag $SECURITY_GROUP_NAME)
if [ -z "$SG_ID" ] ; then
  echo "Security Group $SECURITY_GROUP_NAME not found. Creating it."
  ./2_create_security_group.sh
fi

SUBNET_PUBL_AZ1="VpcWithTwoPublicSubnetsForEks-PublicSubnet01"
BASTION_NAME="bastion-public-subnet-az1"
run_instance_with_key_pair $BASTION_NAME $SECURITY_GROUP_NAME $SUBNET_PUBL_AZ1 demo-15-21-58_key
INSTANCE_ID=$(find_ec2_running_instance_by_name $BASTION_NAME)
describe_running_instance "$INSTANCE_ID"

SUBNET_PUBL_AZ1="VpcWithTwoPublicSubnetsForEks-PublicSubnet02"
BASTION_NAME="bastion-public-subnet-az2"
run_instance_with_key_pair $BASTION_NAME $SECURITY_GROUP_NAME $SUBNET_PUBL_AZ1 demo-15-21-58_key
INSTANCE_ID=$(find_ec2_running_instance_by_name $BASTION_NAME)
describe_running_instance "$INSTANCE_ID"
