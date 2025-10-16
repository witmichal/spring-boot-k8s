source /Users/michal.wit/workspace/dev_util_scripts/awscli_env/ec2_functions/find_security_group_id_by_name_tag.sh
source /Users/michal.wit/workspace/dev_util_scripts/awscli_env/vpc_functions/find_vpc_id_by_name_tag.sh

SECURITY_GROUP_ID=$(find_security_group_id_by_name_tag witm-training-sg-ssh-http-icmp)

export ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text | xargs echo)
if [[ $ACCOUNT_ID != "709931167372" ]]; then
  echo "set AWS_PROFILE to point to personal AWS account (709931167372) or configure AWS CLI"
  exit 1
else 
  echo "OK! Using AWS personal account $ACCOUNT_ID"
fi

export AWS_REGION=eu-central-1

export CLUSTER_NAME=michal-wit-training
export VPC_NAME=VpcWithTwoPublicSubnetsForEks-VPC

VPC_ID=$(find_vpc_id_by_name_tag $VPC_NAME)

PRIVATE_SUBNETS=$(
aws ec2 describe-subnets \
    --filters "Name=vpc-id,Values=$VPC_ID" "Name=tag:aws:cloudformation:logical-id,Values=PrivateSubnet*"\
    --query "Subnets[].SubnetId" \
    --output text | xargs echo
)

#PRIVATE_SUBNETS_ARRAY=(${(@s: :)PRIVATE_SUBNETS})
#PRIVATE_SUBNETS_ARRAY=(${(@s: :)PRIVATE_SUBNETS})
IFS=' ' read -r -a PRIVATE_SUBNETS_ARRAY <<< "$PRIVATE_SUBNETS"

for element in "${PRIVATE_SUBNETS_ARRAY[@]}"
do
    echo "$element"
done
function find_az_for_subnet() {
   aws ec2 describe-subnets \
      --subnet-id $1  \
      --query 'Subnets[0].AvailabilityZone' \
      --output text | xargs
}

PRIVATE_SUBNETS_ARRAY_1_AZ=$(find_az_for_subnet ${PRIVATE_SUBNETS_ARRAY[0]})
PRIVATE_SUBNETS_ARRAY_2_AZ=$(find_az_for_subnet ${PRIVATE_SUBNETS_ARRAY[1]})


echo "$PRIVATE_SUBNETS_ARRAY_1_AZ: { id: ${PRIVATE_SUBNETS_ARRAY[0]} }"
echo "$PRIVATE_SUBNETS_ARRAY_2_AZ: { id: ${PRIVATE_SUBNETS_ARRAY[1]} }"

INSTANCE_CLASS="m7i-flex.large"
NODE_GROUP_PREFIX="michal-wit-node-group"
NODE_GROUP_1="$NODE_GROUP_PREFIX-1"
NODE_GROUP_2="$NODE_GROUP_PREFIX-2"

cat <<EOF | eksctl create cluster -f -
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig
metadata:
  name: $CLUSTER_NAME
  region: $AWS_REGION
  version: "1.33"
vpc:
  subnets:
    private:
      $PRIVATE_SUBNETS_ARRAY_1_AZ: { id: ${PRIVATE_SUBNETS_ARRAY[0]} }
      $PRIVATE_SUBNETS_ARRAY_2_AZ: { id: ${PRIVATE_SUBNETS_ARRAY[1]} }
iam:
  withOIDC: true  # Required for IRSA
autoModeConfig:
  enabled: false
managedNodeGroups:
  - name: $NODE_GROUP_1
    privateNetworking: true
    instanceType: $INSTANCE_CLASS
    minSize: 1
    desiredCapacity: 1
    subnets:
      - ${PRIVATE_SUBNETS_ARRAY[0]}
    securityGroups:
      attachIDs:
        - $SECURITY_GROUP_ID
EOF

aws eks wait cluster-active --name $CLUSTER_NAME

aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME
kubectl cluster-info
