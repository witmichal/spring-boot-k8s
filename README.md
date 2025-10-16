# Getting Started

```shell
./gradlew build
docker build -t michalwit/boot-demo:001 .
docker image push michalwit/boot-demo:001
```

```shell
minikube start

cd k8s
k create -f deployment.yaml
k create -f service.yaml
k get pods -n test
k port-forward service/demo -n test 6666:8888
curl 127.0.0.1:6666

k port-forward -n test pod/readiness-http 8080 8080
```

## 3. enable ingress addon in minikube (Ingress-Nginx Controller)
```shell
minikube addons enable ingress
```


## kubectl get YAML entry and convert to JSON
```shell
 kubectl get cm -o json -n test test | jq -r ".data.\"config.json\"" | yq -o json
```

## get YAML, transform to JSON, display it
```shell
RESP=$(curl -sS https://raw.githubusercontent.com/witmichal/spring-boot-apps-config/refs/heads/main/spring-boot-k8s/application.yaml | yq -o json)
kubectl create configmap test -n test --from-literal=config_json=$RESP
kubectl get cm -o json -n test test | jq -r ".data.config_json"
```

# Python / poetry

## Setup / install

### install dependencies - from repo root
```shell
poetry env use python3.8
poetry install
```

## Usage

### verify env
```shell
poetry env info
```

### activate env
```shell
poetry_activate # alias for `source $(poetry env info --path)/bin/activate`
# poeact
# deact
```
