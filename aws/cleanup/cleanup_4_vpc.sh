export VPC_CF_STACK_NAME=VpcWithTwoPublicSubnetsForEks

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
"$SCRIPT_DIR"/cleanup_2_security_groups.sh

__delete_load_balancers() {
  LBS=$(
    aws elbv2 describe-load-balancers \
    | jq -r '.LoadBalancers | map(.LoadBalancerArn) | join("\n")'
  )
  echo "$LBS" | xargs -I {} echo "Removing load-balancer {}"
  echo "$LBS" | xargs -I {} aws elbv2 delete-load-balancer --load-balancer-arn {}
}

echo "Deleting load balancers"
__delete_load_balancers

echo "Deleting VPC CF stack"
aws cloudformation delete-stack --stack-name $VPC_CF_STACK_NAME --output json | jq

echo "Waiting for VPC CF stack deletion"
aws cloudformation wait stack-delete-complete --stack-name $VPC_CF_STACK_NAME
