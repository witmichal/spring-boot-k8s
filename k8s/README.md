# minikube + kubectl

## ALL IN ONE
```sh
./create_deployment_\&_service.sh
```

## start minikube
minikube start

## publish docker image to minikube docker engine (see https://minikube.sigs.k8s.io/docs/commands/docker-env/)
eval $(minikube docker-env)
docker-compose build

## create namespace (test)
```sh
k create namespace test
```

## create secret
```sh
k create -f ./secret.yaml
k create -f deployment.yaml
k get pods -n test # should display 1 row
k get deployments -n test # should display 1 row
k get services -n test # should display NONE rows
```

## get pod name
```sh
POD=$(kubectl get pod -n test -l app=app-with-db -o jsonpath="{.items[0].metadata.name}")
```

## test pure pod
```sh
k get pod -n=test -o=jsonpath='{.status}' $POD | jq '{node_IP:.hostIP, pod_IP:.podIP}'
k run -i --tty busybox --image=busybox --restart=Never -- sh
# inside busybox:
# telnet {POD IP - fetched with "k get pod -n=test -o=jsonpath='{.status}' $POD | jq '{node_IP:.hostIP, pod_IP:.podIP}'"} {exposed port - 5000?}
# eg. telnet 10.244.0.39 5000
# then "GET /"
# single POD can be easily accesed with its (POD's) kubernetes IP
k delete pod busybox
```

### connect to pod
```sh
k run -i --tty busybox --image=busybox --restart=Never -- sh
# inside busybox:
# telnet {service IP} {exposed port - 5000?}
# eg. telnet xxx.xxx.xxx.xxx 5000
# then "GET /"
k delete pod busybox
```

## test service
```sh
# 1. create a service
k create -f service.yaml

# 2. create tunnel to the service

# 2.1 kubectl port-forwart
k port-forward service/app-with-db -n test 6666:5555
curl 127.0.0.1:6666 

# 2.2 OR minikube service (opens a tunnel)
minikube service -n test demo --url # service is the name of the SERVICE not a pod (checkout output of `k get service -n=test`)
curl 127.0.0.1:{random-port-from-minikube-service-command} 

# 2.3 WITH ingress (nginx)
# start tunnel
minikube tunnel
# in another terminal window
# it hits 127.0.0.1 (on default 80 port) and in k8s the post is still http://hello-world.example
curl --resolve "hello-world.example:80:127.0.0.1" -i http://hello-world.example
```

## busybox with curl
```shell
k run -n test busybox -i --tty --image=radial/busyboxplus:curl --restart=Never -- sh
```