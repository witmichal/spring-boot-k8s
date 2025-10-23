kubectl config use-context minikube

# CPU Keda scaler reuires Kubernetes Metrics Server
minikube addons enable metrics-server

# test KMS
kubectl top pods

