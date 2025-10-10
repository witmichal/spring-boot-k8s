ACCOUNT_ID=$(aws sts get-caller-identity --output json | jq -r '.Account' | xargs)
if [[ $ACCOUNT_ID != "709931167372" ]]; then
  echo "set AWS_PROFILE to point to personal AWS account (709931167372) or configure AWS CLI"
  exit 1
else
  echo "OK! Using AWS personal account $ACCOUNT_ID"
fi

# STEP 1: Create IAM Role

AWS_REGION=eu-central-1
CLUSTER_NAME=michal-wit-training
POLICY_NAME="AWSLoadBalancerControllerIAMPolicy"
IAM_SERVICE_ACCOUNT_NAME="aws-load-balancer-controller"

curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.13.3/docs/install/iam_policy.json

aws iam create-policy \
    --policy-name $POLICY_NAME \
    --policy-document "file://./iam_policy.json"

# Error: unable to create iamserviceaccount(s) without IAM OIDC provider enabled
eksctl utils associate-iam-oidc-provider --region=$AWS_REGION --cluster $CLUSTER_NAME --approve

eksctl create iamserviceaccount \
    --cluster=$CLUSTER_NAME \
    --namespace=kube-system \
    --name=$IAM_SERVICE_ACCOUNT_NAME \
    --attach-policy-arn=arn:aws:iam::${ACCOUNT_ID}:policy/AWSLoadBalancerControllerIAMPolicy \
    --override-existing-serviceaccounts \
    --region $AWS_REGION \
    --approve

rm iam_policy.json

# STEP 2: Install AWS Load Balancer Controller

helm repo add eks https://aws.github.io/eks-charts
helm repo update eks

VPC_ID=$(aws cloudformation describe-stacks --stack-name VpcWithTwoPublicSubnetsForEks --query "Stacks[0].Outputs[?OutputKey=='VpcId'].OutputValue" --output text)

helm upgrade -i aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set vpcId="$VPC_ID" \
  --set clusterName="$CLUSTER_NAME" \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set clusterSecretsPermissions.allowAllSecrets=false \
  --version 1.14.0
