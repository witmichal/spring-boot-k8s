echo "################################### NOTE: #######################################"
echo "### As you can see there's an issue with customisation of a script like this ####"
echo "#################################################################################"

# cleanup
kubectl delete namespace test

set -e

# create namespace
kubectl create namespace test

# create other resources
kubectl create -f ./resources.yaml
POD=$(kubectl get pod -n test -l app=demo-a -o jsonpath="{.items[0].metadata.name}")
kubectl wait -n test --for=condition=Ready pods/$POD

echo
echo "stream logs (-f, --follow is for opening a stream):"
echo "# k logs -f -n test services/demo"
echo
echo "To expose the service on localhost and port 6666"
echo "kubectl port-forward service/demo -n test 6666:8888"
echo
echo "Test:"
echo "curl 127.0.0.1:6666"
echo
