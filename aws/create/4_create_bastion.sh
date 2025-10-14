source /Users/michal.wit/workspace/dev_util_scripts/awscli_env/ec2_functions/run_instance_with_key_pair.sh
source /Users/michal.wit/workspace/dev_util_scripts/awscli_env/vpc_functions/find_vpc_id_by_name_tag.sh
source /Users/michal.wit/workspace/dev_util_scripts/awscli_env/ec2_functions/import_key_pair.sh
source /Users/michal.wit/workspace/dev_util_scripts/awscli_env/ec2_functions/find_ec2_running_instance_by_name.sh


VPC_NAME="VpcWithTwoPublicSubnetsForEks-VPC"
VPC_ID=$(find_vpc_id_by_name_tag $VPC_NAME)

if [ -z "${VPC_ID}" ] ; then
   echo "VPC_ID not found for VPC_NAME: $VPC_NAME"
   exit 1
fi

echo $VPC_ID
SUBNET_ID=$(
aws ec2 describe-subnets \
    --filters "Name=vpc-id,Values=$VPC_ID" "Name=tag:aws:cloudformation:logical-id,Values=PublicSubnet*"\
    --query "Subnets[0].SubnetId" \
    --output text | xargs echo
)

if [ -z "${SUBNET_ID}" ] ; then
   echo "SUBNET_ID not found for VPC_ID: $VPC_ID"
   exit 1
fi

SUBNET_NAME=$(
aws ec2 describe-subnets \
  --subnet-ids $SUBNET_ID \
  --query "Subnets[0].Tags[?Key=='Name'].Value" \
  --output text | xargs echo
)

if [ -z "${SUBNET_NAME}" ] ; then
   echo "SUBNET_NAME not found for SUBNET_ID: $SUBNET_ID"
   exit 1
fi

KEY_NAME="demo-$(date "+%H-%M-%S")_key"
import_key_pair $KEY_NAME "$HOME/personalspace/spring-boot-k8s/aws/create/aws_id_rsa.pub"

echo "SSH:"
echo "user: 'ec2-user' - for AWS distributions / 'ubuntu' - for Ubuntu"
echo "ssh -i \"$HOME/personalspace/spring-boot-k8s/aws/create/aws_id_rsa\" ec2-user@<BASTION_PUBLIC_IP>"
echo "OR"
echo "ssh -i \"$HOME/personalspace/spring-boot-k8s/aws/create/aws_id_rsa\" ubuntu@<BASTION_PUBLIC_IP>"
echo "dig <LOAD_BALANCER_PUBLIC_DNS>"
echo "curl --resolve \"hello-world.example:80:<LOAD_BALANCER_PUBLIC_IP>\" hello-world.example"

SG_NAME="witm-training-sg-ssh-http-icmp"
run_instance_with_key_pair bastion $SG_NAME $SUBNET_NAME $KEY_NAME

INSTANCE_ID=$(find_ec2_running_instance_by_name bastion)

aws ec2 describe-instances --instance-ids $INSTANCE_ID \
| jq '.Reservations[0].Instances[0] | {s:.SubnetId,v:.VpcId,pr:.PrivateIpAddress,pu:.PublicIpAddress,id:.InstanceId}'
