echo "Should whole infra by provisioned [y/n]:"
read -s mainmenuinput
case $mainmenuinput in
    y) ;;
    *) echo "Not provisioning anything."; return 0 ;;
esac

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
--template-body "file://$HOME/personalspace/spring-boot-k8s/aws/create/amazon-eks-vpc.yaml" \
--region $AWS_REGION | xargs echo

aws cloudformation wait stack-create-complete --stack-name $VPC_CF_STACK_NAME

echo "VPN creation finished:\n$(date)"
