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
kubectl wait -n test --for=condition=Ready pods/$POD

echo
echo "### stream logs [TAIL] (-f, --follow is for opening a stream):"
echo "kubectl logs -f -n test services/demo"
echo
echo "### To expose ingress"
echo "minikube tunnel"
echo
echo "### Test:"
echo "curl --resolve \"hello-world.example:80:127.0.0.1\" -i http://hello-world.example"
echo
