echo "################################### NOTE: #######################################"
echo "### As you can see there's an issue with customisation of a script like this ####"
echo "#################################################################################"

# cleanup
kubectl delete namespace test

set -e

# create namespace
kubectl create namespace test

SERVICE_NAME="kube-a" # supporting 'kube-b' without helm chart / `kustomization` would be a hell of an issue

# create configmap - manually (will improve with helm chart later)
rm -f app_config.yaml app_config.json
RAW_YAML_FROM_GH="https://raw.githubusercontent.com/witmichal/spring-boot-apps-config/refs/heads/main/$SERVICE_NAME/application.yaml"
curl --output app_config.yaml -sS $RAW_YAML_FROM_GH
yq app_config.yaml -o=json > app_config.json
kubectl create configmap test -n test --from-file=config_json=app_config.json
rm -f app_config.yaml app_config.json

# INFO log
echo "configmap created - content:"
kubectl get cm -o json -n test test | jq -r ".data.config_json"

# create other resources
kubectl create -f ./resources.yaml
POD=$(kubectl get pod -n test -l app=demo -o jsonpath="{.items[0].metadata.name}")
kubectl wait --for='jsonpath={.status.conditions[?(@.type=="Ready")].status}=True' -n test pods/$POD

echo
echo "stream logs (-f, --follow is for opening a stream):"
echo "# k logs -f -n test services/demo"
echo
echo "CTRL+C to kill the tunnel process"
echo "hit 'curl 127.0.0.1:6666' in separate shell"
echo

#kubectl port-forward service/demo -n test 6666:8888
