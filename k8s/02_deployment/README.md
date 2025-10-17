```shell
###stream logs (-f, --follow is for opening a stream):
kubectl logs -f -n test services/demo

### 8080 is the SpringBoot port - exposed by PODs!
### To expose the service on localhost and port 5555
kubectl port-forward deployment/demo -n test 5555:8080
# this operation is buggy, pods and deployments shouldn't be exposed in any way

### Test:
curl 127.0.0.1:5555
```

# Demo 02

### Create deployment
```shell
kubectl create ns test                             
kubectl apply -f ./02_four_pods_rolling_update.yaml
```

### 1 Rollback
#### Trigger a rolling update [rollout] (with invalid version)
```shell
kubectl set image deployment/demo -n test db-app=michalwit/boot-demo:011
```

#### Execute rollback
```shell
# rollback to a previous revision
kubectl rollout undo deployment/demo -n test

# OR rollback to specific version
# check revisions
kubectl rollout history deployment/demo -n test    
kubectl rollout undo deployment/demo -n test --to-revision=1
```

### 2 Successful rollout

#### Trigger a rolling update [rollout] (with invalid version)
```shell
kubectl set image deployment/demo -n test db-app=michalwit/boot-demo:007
```

#### That's too quick, let's use version 008 and introduce probes to slow down the process