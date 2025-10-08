export VPC_CF_STACK_NAME=VpcWithTwoPublicSubnetsForEks
export CLUSTER_NAME=michal-wit-training

aws eks delete-cluster --name $CLUSTER_NAME --output json | jq
aws eks wait cluster-deleted --name $CLUSTER_NAME

./cleanup_2_security_groups.sh

aws cloudformation delete-stack --stack-name $VPC_CF_STACK_NAME --output json | jq
aws cloudformation wait stack-delete-complete --stack-name $VPC_CF_STACK_NAME
