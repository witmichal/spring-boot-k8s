```shell
###stream logs (-f, --follow is for opening a stream):
kubectl logs -f -n test services/demo

### To expose the service on localhost and port 6666
minikube tunnel

### Test:
curl --resolve "hello-world.example:80:127.0.0.1" -i http://hello-world.example
```


```shell
helm create test-template

cd test-template
rm -fr tests
rm -fr charts
rm .helmignore # needed for helm packaging
rm NOTES.txt # printed when chart is deployed

helm template .

```