helm repo add kedacore https://kedacore.github.io/charts
helm repo update
helm install keda kedacore/keda --namespace keda --create-namespace

# cleanup
# helm uninstall keda -n keda
# kubectl delete namespace keda
