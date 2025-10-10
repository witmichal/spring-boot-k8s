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
aws iam create-role \
    --role-name AmazonEKSAutoClusterRole \
    --assume-role-policy-document "file://$HOME/personalspace/spring-boot-k8s/aws/create/eks-cluster-role-trust-policy.json" \
    --output json | jq

# attach managed policies to the role
aws iam attach-role-policy \
    --role-name $IAM_ROLE_FOR_EKS_CLUSTER \
    --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy
    
aws iam attach-role-policy \
    --role-name $IAM_ROLE_FOR_EKS_CLUSTER \
    --policy-arn arn:aws:iam::aws:policy/AmazonEKSComputePolicy

aws iam attach-role-policy \
    --role-name $IAM_ROLE_FOR_EKS_CLUSTER \
    --policy-arn arn:aws:iam::aws:policy/AmazonEKSBlockStoragePolicy

aws iam attach-role-policy \
    --role-name $IAM_ROLE_FOR_EKS_CLUSTER \
    --policy-arn arn:aws:iam::aws:policy/AmazonEKSLoadBalancingPolicy

aws iam attach-role-policy \
    --role-name $IAM_ROLE_FOR_EKS_CLUSTER \
    --policy-arn arn:aws:iam::aws:policy/AmazonEKSNetworkingPolicy
    
aws iam list-attached-role-policies --role-name $IAM_ROLE_FOR_EKS_CLUSTER --output json | jq

# create role with trust policy from file
export IAM_ROLE_FOR_EKS_NODE=AmazonEKSAutoNodeRole
aws iam create-role \
    --role-name $IAM_ROLE_FOR_EKS_NODE \
    --assume-role-policy-document "file://$HOME/personalspace/spring-boot-k8s/aws/create/eks-node-role-trust-policy.json" \
    --output json | jq

# attach managed policies to the role
aws iam attach-role-policy \
    --role-name $IAM_ROLE_FOR_EKS_NODE \
    --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodeMinimalPolicy

aws iam attach-role-policy \
    --role-name $IAM_ROLE_FOR_EKS_NODE \
    --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly

aws iam list-attached-role-policies --role-name $IAM_ROLE_FOR_EKS_NODE --output json | jq
