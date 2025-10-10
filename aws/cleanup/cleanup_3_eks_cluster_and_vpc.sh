export VPC_CF_STACK_NAME=VpcWithTwoPublicSubnetsForEks
export CLUSTER_NAME=michal-wit-training

aws eks delete-cluster --name $CLUSTER_NAME --output json | jq
aws eks wait cluster-deleted --name $CLUSTER_NAME

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

__delete_load_balancers

aws cloudformation delete-stack --stack-name $VPC_CF_STACK_NAME --output json | jq
aws cloudformation wait stack-delete-complete --stack-name $VPC_CF_STACK_NAME
