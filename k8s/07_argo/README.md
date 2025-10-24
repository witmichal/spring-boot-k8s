```shell
kubectl config use-context minikube
kubectl port-forward svc/argocd-server -n argocd 8888:443
kubectl apply 
```


# Usage
### create an Application in ArgoCD

1. make the repository public in GH (https://github.com/witmichal/kubernetes_training)
2. execute `argocd app create`
```shell
#argocd app delete app-with-db
argocd app create test-helm \
--repo 'https://github.com/witmichal/spring-boot-k8s.git' \
--dest-namespace test-helm \
--dest-server https://kubernetes.default.svc \
--path k8s/06_helm/helm-chart-demo
```
3. synch app (deploy to cluster)
```shell
argocd app sync app-with-db
```
4. restart Deployment (used by UP on main service pipeline / after merging to main)
```shell
# used by 1 (merge do `main`) - {up-service}/job/main -> eks-rolling-update-deploy (argocd-deployment-validation.py) 
# used by 2 (restart na EKS) - up-eks-application-restart -> argocd-restart-application
argocd app actions run app-with-db restart --kind Deployment
```

# Installation

## ArgoCD in minikube Installation
```shell
# ArgoCD requires a namespace with its name
kubectl create ns argocd

# apply ArgoCD manifest installation file from ArgoCD github repository
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v3.1.7/manifests/install.yaml
```

### Verify installation
```shell
kubectl get all -n argocd
```

### Access web UI
```shell
kubectl port-forward svc/argocd-server -n argocd 8888:443
```

### Retrieve password from k8s secret
```shell
ARGO_PASS=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo -n | xargs)
```

### change password
```shell
argocd login localhost:8888 --username admin --password $ARGO_PASS
argocd account update-password --current-password $ARGO_PASS --account admin --new-password secretpassword
```

### uninstall
```shell
kubectl delete -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v3.1.7/manifests/install.yaml
```

## ArgoCD CLI

### Install - MAC (m1 - ARM)
```shell
ARGO_VERSION="v3.1.7"
curl -sSL -o argocd https://github.com/argoproj/argo-cd/releases/download/$ARGO_VERSION/argocd-darwin-arm64
sudo install -m 555 argocd /usr/local/bin/argocd
rm argocd
```

# INFO

`argocd` is the main tool used by UP to update k8s resources.
Please see a script `argocd-deployment-validation.py` in repo `devops-jenkins-shared-library` (https://github.com/viacomcbs/devops-jenkins-shared-library) (already cloned).

The underlying python function that gets triggered is:
```python
def restart_argocd_application(argocd_server, argocd_app, token):
    token_opt = f"--auth-token={token}"
    command =  " ".join([
        f"argocd app actions run {argocd_app}",
        "restart --kind Deployment",
        f"{token_opt if token != '' else ''}",
        f"--server {argocd_server}",
        "--grpc-web",
    ])

    run(command, shell=True)
```