export AWS_REGION="eu-central-1"
export CLUSTER_NAME="michal-wit-training"
export IAM_SERVICES_ACCOUNT_NAME="irsa-s3-reader-s-a"
export IAM_SERVICES_ACCOUNT_ROLE_NAME="S3-Reader-Role-For-Irsa"
export TEST_NAMESPACE="test"

eksctl utils associate-iam-oidc-provider --region=$AWS_REGION --cluster $CLUSTER_NAME --approve

export S3_READ_POLICY_ARN="arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"

# cleanup
eksctl delete iamserviceaccount \
  --name irsa-s3-reader-sa \
  --cluster "$CLUSTER_NAME" \
  --namespace "$TEST_NAMESPACE"

# S3 reader Service Account
eksctl create iamserviceaccount \
  --name "$IAM_SERVICES_ACCOUNT_NAME" \
  --namespace "$TEST_NAMESPACE" \
  --cluster "$CLUSTER_NAME" \
  --role-name $IAM_SERVICES_ACCOUNT_ROLE_NAME \
  --role-only \
  --attach-policy-arn "$S3_READ_POLICY_ARN" \
  --approve
