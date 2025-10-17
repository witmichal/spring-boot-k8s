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
