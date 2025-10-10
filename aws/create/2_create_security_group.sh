source /Users/michal.wit/workspace/dev_util_scripts/awscli_env/vpc_functions/find_vpc_id_by_name_tag.sh

set -e

__create_security_group () {
  if [ $# -lt 2 ] ; then
    echo "usage:"
    echo "__create_security_group <SG_NAME> <VPC_ID> "
    printf "e.g: \n\t __create_security_group witm-training-sg {witm-training-vpd-ID}\n"
    return 1
  fi

  SG_NAME=$1
  VPC_ID=$2

  # SG needs to be crated in the same VPC as EC2 instances in order to assign SG to them
  SG_ID=$(
    aws ec2 create-security-group \
      --group-name $SG_NAME \
      --vpc-id $VPC_ID \
      --description "SG for allowing SSH-HTTPS ports and ICMP" \
      --tag-specifications "ResourceType=security-group,Tags=[{Key=Name,Value=$SG_NAME}]" \
      --query "GroupId" \
      --output text
  )

  echo "SG_ID: $SG_ID"

  # FromPort=-1,ToPort=-1  -> "-1" is a wildcard (all)
  aws ec2 authorize-security-group-ingress \
    --group-id $SG_ID \
    --ip-permissions \
      IpProtocol=icmp,FromPort=-1,ToPort=-1,IpRanges="[{CidrIp=0.0.0.0/0}]" \
      IpProtocol=tcp,FromPort=22,ToPort=443,IpRanges="[{CidrIp=0.0.0.0/0}]" \
    --output json | jq

  aws ec2 authorize-security-group-ingress \
    --group-id $SG_ID \
    --source-group $SG_ID \
    --protocol all \
    --output json | jq

  # FromPort=-1,ToPort=-1  -> "-1" is a wildcard (all)
  aws ec2 authorize-security-group-egress \
    --group-id $SG_ID \
    --ip-permissions \
      IpProtocol=icmp,FromPort=-1,ToPort=-1,IpRanges="[{CidrIp=0.0.0.0/0}]" \
      IpProtocol=tcp,FromPort=22,ToPort=443,IpRanges="[{CidrIp=0.0.0.0/0}]" \
    --output json | jq

  aws ec2 authorize-security-group-egress \
    --group-id $SG_ID \
    --source-group $SG_ID \
    --protocol all \
    --output json | jq
}

echo "SG creation started:\n$(date)"

VPC_NAME="VpcWithTwoPublicSubnetsForEks-VPC"
VPC_ID=$(find_vpc_id_by_name_tag $VPC_NAME)
SG_NAME="witm-training-sg-ssh-http-icmp"
echo "SG_NAME: $SG_NAME"
echo "VPC_ID: $VPC_ID"

# create SECURITY GROUP
echo "__create_security_group $SG_NAME $VPC_ID"
__create_security_group $SG_NAME $VPC_ID
# !create SECURITY GROUP

echo "SG creation finished:\n$(date)"