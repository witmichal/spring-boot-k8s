echo "################################### NOTE: #######################################"
echo "### As you can see there's an issue with customisation of a script like this ####"
echo "#################################################################################"

# cleanup
kubectl delete namespace test

set -e

# create namespace
kubectl create namespace test

# create other resources
kubectl create --save-config -f ./02_multiple_services.yaml

POD=$(kubectl get pod -n test -l app=demo-a -o jsonpath="{.items[0].metadata.name}")
kubectl wait -n test --for=condition=Ready pods/$POD

echo
echo "### stream logs [TAIL] (-f, --follow is for opening a stream):"
echo "k logs -f -n test services/demo"
echo
echo "### To expose the service on localhost and port 6666"
echo "minikube service -n test demo"
echo
echo "### Test:"
echo "curl {URL_FROM_OUTPUT}"
echo
