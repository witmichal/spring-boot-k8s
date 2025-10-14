export ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text | xargs echo)
if [[ $ACCOUNT_ID != "709931167372" ]]; then
  echo "set AWS_PROFILE to point to personal AWS account (709931167372) or configure AWS CLI"
  exit 1
else 
  echo "OK! Using AWS personal account $ACCOUNT_ID"
fi

export AWS_REGION=eu-central-1
export CLUSTER_NAME=michal-wit-training
aws eks wait cluster-active --name $CLUSTER_NAME

aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME
kubectl cluster-info

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace

kubectl get all -n ingress-nginx
kubectl get svc -n ingress-nginx # EXTERNAL-IP should be in "pending" state - because no ingress is created
