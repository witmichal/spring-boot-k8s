export ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text | xargs echo)
if [[ $ACCOUNT_ID != "709931167372" ]]; then
  echo "set AWS_PROFILE to point to personal AWS account (709931167372) or configure AWS CLI"
  exit 1
else
  echo "OK! Using AWS personal account $ACCOUNT_ID"
fi

export AWS_REGION="eu-central-1"
export CLUSTER_NAME="michal-wit-training"
export IAM_SERVICES_ACCOUNT_NAME="irsa-s3-reader-s-a"
export IAM_SERVICES_ACCOUNT_ROLE_NAME="S3-Reader-Role-For-Irsa"
export TEST_NAMESPACE="test"

eksctl utils associate-iam-oidc-provider --region=$AWS_REGION --cluster $CLUSTER_NAME --approve

export S3_READ_POLICY_ARN="arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"

########################
## 1. IAM:
########################

# cleanup
eksctl delete iamserviceaccount \
  --name "$IAM_SERVICES_ACCOUNT_NAME" \
  --cluster "$CLUSTER_NAME" \
  --namespace "$TEST_NAMESPACE"

# S3 reader Service Account
# Trust policy is important (see 'Trust Relationships' tab in WEB console)
eksctl create iamserviceaccount \
  --name "$IAM_SERVICES_ACCOUNT_NAME" \
  --namespace "$TEST_NAMESPACE" \
  --cluster "$CLUSTER_NAME" \
  --role-name "$IAM_SERVICES_ACCOUNT_ROLE_NAME" \
  --attach-policy-arn "$S3_READ_POLICY_ARN" \
  --approve

echo "Policies attached to $IAM_SERVICES_ACCOUNT_ROLE_NAME role"
aws iam list-attached-role-policies \
--role-name $IAM_SERVICES_ACCOUNT_ROLE_NAME \
| jq

echo "Trust relationship of $IAM_SERVICES_ACCOUNT_ROLE_NAME role"
aws iam get-role --role-name $IAM_SERVICES_ACCOUNT_ROLE_NAME \
--query 'Role.AssumeRolePolicyDocument' \
--role-name $IAM_SERVICES_ACCOUNT_ROLE_NAME \
| jq

########################
## 2. EKS:
########################

### create SA in k8s
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: "$IAM_SERVICES_ACCOUNT_NAME"
  namespace: "$TEST_NAMESPACE"
EOF

IAM_ROLE_ARN=$(
  aws iam get-role --role-name $IAM_SERVICES_ACCOUNT_ROLE_NAME \
  --query 'Role.Arn' \
  --role-name $IAM_SERVICES_ACCOUNT_ROLE_NAME \
  --output text
)
kubectl get serviceaccounts -n "$TEST_NAMESPACE" # just test output

### add annotation to SA
kubectl annotate serviceaccount "$IAM_SERVICES_ACCOUNT_NAME" \
-n "$TEST_NAMESPACE" \
eks.amazonaws.com/role-arn="$IAM_ROLE_ARN"

kubectl describe sa -n "$TEST_NAMESPACE" "$IAM_SERVICES_ACCOUNT_NAME" # just test output

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: s3-access-test
  namespace: $TEST_NAMESPACE
spec:
  serviceAccountName: $IAM_SERVICES_ACCOUNT_NAME
  containers:
    - name: aws-cli
      image: amazon/aws-cli:latest
      command: ["/bin/sh", "-c"]
      args: ["sleep 3600"]
EOF

echo "kubectl exec -it s3-access-test -n $TEST_NAMESPACE -- /bin/sh"
echo "aws s3api list-buckets"
