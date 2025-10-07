## Walkthrough

### Following resources (among others) will be created:
1. VPC
2. subnets (2 private + 2 public)
3. EKS cluster

EKS cluster in AWS using AWS CLI and kubectl.
The auto-mode (AWS managed node groups) is used to create the cluster.

### EC2 instances are created LAZILY
The EC2 instances are created lazily. I.e. only when a pod is being deployed.


### AWS docs used:
1. https://docs.aws.amazon.com/eks/latest/userguide/creating-a-vpc.html
2. https://docs.aws.amazon.com/eks/latest/userguide/automode-get-started-cli.html

### Steps:

1. create CF stack:
```shell
export ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text | xargs echo)
if [[ $ACCOUNT_ID != "709931167372" ]]; then
  echo "set AWS_PROFILE to point to personal AWS account (709931167372) or configure AWS CLI"
  exit 1
else 
  echo "OK! Using AWS personal account $ACCOUNT_ID"
fi

export AWS_REGION=eu-central-1
export CLUSTER_NAME=michal-wit-training
export VPC_CF_STACK_NAME=VpcWithOnePubAndOnePrivSubnetsForEks
aws cloudformation create-stack \
--stack-name $VPC_CF_STACK_NAME \
--template-body "file://./aws/auto-mode/amazon-eks-vpc-private-and-public-subnets.yaml" \ 
--region $AWS_REGION
```

2. create IAM role for EKS cluster:
```shell
# create role with trust policy from file
export IAM_ROLE_FOR_EKS_CLUSTER=AmazonEKSAutoClusterRole
aws iam create-role \
    --role-name AmazonEKSAutoClusterRole \
    --assume-role-policy-document "file://./aws/auto-mode/eks-cluster-role-trust-policy.json"
AWS_ROLE_ARN=$(aws iam get-role --role-name AmazonEKSAutoClusterRole --query "Role.Arn" --output text)

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
```

3. create IAM role for EKS node:
```shell
# create role with trust policy from file
export IAM_ROLE_FOR_EKS_NODE=AmazonEKSAutoNodeRole
aws iam create-role \
    --role-name $IAM_ROLE_FOR_EKS_NODE \
    --assume-role-policy-document "file://./aws/auto-mode/eks-node-role-trust-policy.json"
AWS_NODE_ROLE_ARN=$(aws iam get-role --role-name $IAM_ROLE_FOR_EKS_NODE --query "Role.Arn" --output text)

# attach managed policies to the role
aws iam attach-role-policy \
    --role-name $IAM_ROLE_FOR_EKS_NODE \
    --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodeMinimalPolicy

aws iam attach-role-policy \
    --role-name $IAM_ROLE_FOR_EKS_NODE \
    --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly
```


4. create EKS cluster:
```shell
export SUBNET_IDS=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=$VPC_CF_STACK_NAM*" | jq -r '.Subnets | map(.SubnetId) | join(" ")')
export RESOURCE_VPC_CONFIG=$(jq -nc '{subnetIds: ($ARGS.positional[0] | split(" ")),endpointPublicAccess:true,endpointPrivateAccess:true}' --args $SUBNET_IDS)
export COMPUTE_CONFIG=$(jq -cn  --arg one 'Apple' --arg nodeRoleArn "$AWS_NODE_ROLE_ARN" '{enabled: true, nodeRoleArn: $nodeRoleArn, nodePools: ["general-purpose","system"]}')
aws eks create-cluster \
  --region $AWS_REGION \
  --name $CLUSTER_NAME \
  --kubernetes-version 1.33 \
  --role-arn $AWS_ROLE_ARN \
  --resources-vpc-config=${RESOURCE_VPC_CONFIG} \
  --compute-config=${COMPUTE_CONFIG} \
  --kubernetes-network-config '{"elasticLoadBalancing": {"enabled": true}}' \
  --storage-config '{"blockStorage": {"enabled": true}}' \
  --access-config '{"authenticationMode": "API"}'
  
while [ "$(aws eks describe-cluster --name $CLUSTER_NAME | jq -r '.cluster.status')" != "ACTIVE" ]; do
  aws eks describe-cluster --name $CLUSTER_NAME | jq -r '.cluster.status'
  sleep 2
done
```

5. configure kubectl to communicate with newly created EKS cluster:
```shell
aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME
kubectl cluster-info
```

6. create ingress-nginx namespace and install ingress-nginx using helm:
```shell
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace
```
7. verify installation:
```shell
kubectl get all -n ingress-nginx
```