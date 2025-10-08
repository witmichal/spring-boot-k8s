echo "VPN creation started:\n$(date)"

export ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text | xargs echo)
if [[ $ACCOUNT_ID != "709931167372" ]]; then
  echo "set AWS_PROFILE to point to personal AWS account (709931167372) or configure AWS CLI"
  exit 1
else 
  echo "OK! Using AWS personal account $ACCOUNT_ID"
fi

export AWS_REGION=eu-central-1
export VPC_CF_STACK_NAME=VpcWithTwoPublicSubnetsForEks
aws cloudformation create-stack \
--stack-name $VPC_CF_STACK_NAME \
--template-body "file://amazon-eks-vpc-only-public-subnets.yaml" \
--region $AWS_REGION | xargs echo

aws cloudformation wait stack-create-complete --stack-name $VPC_CF_STACK_NAME

echo "VPN creation finished:\n$(date)"
