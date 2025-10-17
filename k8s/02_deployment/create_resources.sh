echo "################################### NOTE: #######################################"
echo "### As you can see there's an issue with customisation of a script like this ####"
echo "#################################################################################"

# cleanup
kubectl delete namespace test

set -e

# create namespace
kubectl create namespace test

# create other resources
kubectl create --save-config -f ./01_one_pod.yaml

POD=$(kubectl get pod -n test -l app=demo -o jsonpath="{.items[0].metadata.name}")
kubectl wait -n test --for=condition=Ready pods/$POD

echo
echo "### stream logs [TAIL] (-f, --follow is for opening a stream):"
echo "k logs -f -n test services/demo"
echo
echo "### 8080 is the SpringBoot port - exposed by PODs!"
echo "### To expose the service on localhost and port 5555"
echo "kubectl port-forward deployment/demo -n test 5555:8080"
echo
echo "### if that doesn't work - simply add a service:"
echo "kubectl expose deployment/kubernetes-bootcamp --type=\"NodePort\" --port 5555"
echo
echo "### Test:"
echo "curl 127.0.0.1:5555"
echo
