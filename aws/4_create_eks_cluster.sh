source /Users/michal.wit/workspace/dev_util_scripts/awscli_env/ec2_functions/find_security_group_id_by_name_tag.sh

SECURITY_GROUP_ID=$(find_security_group_id_by_name_tag witm-training-sg-ssh-http-icmp)

export ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text | xargs echo)
if [[ $ACCOUNT_ID != "709931167372" ]]; then
  echo "set AWS_PROFILE to point to personal AWS account (709931167372) or configure AWS CLI"
  exit 1
else 
  echo "OK! Using AWS personal account $ACCOUNT_ID"
fi

export AWS_REGION=eu-central-1

# create role with trust policy from file
export IAM_ROLE_FOR_EKS_CLUSTER=AmazonEKSAutoClusterRole
AWS_ROLE_ARN=$(aws iam get-role --role-name $IAM_ROLE_FOR_EKS_CLUSTER --query "Role.Arn" --output text)

export IAM_ROLE_FOR_EKS_NODE=AmazonEKSAutoNodeRole
AWS_NODE_ROLE_ARN=$(aws iam get-role --role-name $IAM_ROLE_FOR_EKS_NODE --query "Role.Arn" --output text)

export CLUSTER_NAME=michal-wit-training
export VPC_CF_STACK_NAME=VpcWithTwoPublicSubnetsForEks

export SUBNETS=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=${VPC_CF_STACK_NAME}*" | jq -r '.Subnets | map(.SubnetId) | join(" ")' | xargs)
export RESOURCE_VPC_CONFIG=$(jq -nc '{subnetIds: ($ARGS.positional[0] | split(" ")),securityGroupIds:($ARGS.positional[1] | split(" ")),endpointPublicAccess:true,endpointPrivateAccess:true}' --args "$SUBNETS" --args "$SECURITY_GROUP_ID")
export COMPUTE_CONFIG=$(jq -cn  --arg one 'Apple' --arg nodeRoleArn "$AWS_NODE_ROLE_ARN" '{enabled: true, nodeRoleArn: $nodeRoleArn, nodePools: ["general-purpose","system"]}')
echo "compute-config:\t\t$COMPUTE_CONFIG\nresources-vpc-config:\t$RESOURCE_VPC_CONFIG"

aws eks create-cluster \
  --region $AWS_REGION \
  --name $CLUSTER_NAME \
  --kubernetes-version 1.33 \
  --role-arn $AWS_ROLE_ARN \
  --resources-vpc-config=${RESOURCE_VPC_CONFIG} \
  --compute-config=${COMPUTE_CONFIG} \
  --kubernetes-network-config '{"elasticLoadBalancing": {"enabled": true}}' \
  --storage-config '{"blockStorage": {"enabled": true}}' \
  --access-config '{"authenticationMode": "API"}' \
  --output json | jq
  
aws eks wait cluster-active --name $CLUSTER_NAME

aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME
kubectl cluster-info

HELLO_WORLD_POD=hello-world
kubectl get nodes # no nodes yet - because no pod is deployed yet
kubectl create namespace test
kubectl run -n test $HELLO_WORLD_POD --image=registry.k8s.io/e2e-test-images/agnhost:2.53 --restart=Never
kubectl wait --for=condition=Ready pod/$HELLO_WORLD_POD -n test --timeout=300s
kubectl get nodes
kubectl delete pods -n test $HELLO_WORLD_POD

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace

kubectl get all -n ingress-nginx
kubectl get svc -n ingress-nginx # EXTERNAL-IP should be in "pending" state - because no ingress is created
