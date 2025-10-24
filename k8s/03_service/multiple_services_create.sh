echo "################################### NOTE: #######################################"
echo "### As you can see there's an issue with customisation of a script like this ####"
echo "#################################################################################"

# cleanup
kubectl delete namespace test-service-multiple

set -e

# create namespace
kubectl create namespace test-service-multiple

# create other resources
kubectl create --save-config -f ./multiple_services.yaml

POD=$(kubectl get pod -n test-service-multiple -l app=demo-a -o jsonpath="{.items[0].metadata.name}")
kubectl wait -n test-service-multiple --for=condition=Ready pods/$POD

echo
echo "### stream logs [TAIL] (-f, --follow is for opening a stream):"
echo "k logs -f -n test-service-multiple services/demo-a"
echo
echo "### To expose the service on localhost and port 6666"
echo "minikube service -n test-service-multiple demo-a"
echo
echo "### Test:"
echo "curl {URL_FROM_OUTPUT}"
echo
