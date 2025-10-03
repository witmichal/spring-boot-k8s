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
