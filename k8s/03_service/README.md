```shell
###stream logs (-f, --follow is for opening a stream):
kubectl logs -f -n test-serice-multiple services/demo

minikube service -n test-serice-multiple demo-a
minikube service -n test-serice-multiple demo-b

### Test:
curl {URL_FROM_OUTPUT}
```


```shell
echo "to communicate with LoadBalancer service, run (from within EC2 instance in the same VPN)
:"
curl <DNS-of-created-load-balancer>:<spec.ports.port>

echo "E.G."
curl k8s-test-demoa-51d794a2b3-af7daa31cbb4c67b.elb.eu-central-1.amazonaws.com:8888
```

```shell
# minikube is buggy in terms of DNS and service discovery:
kubectl logs --namespace=kube-system -l k8s-app=kube-dns
```


```mermaid
graph LR;
  client([client])-. Service-managed <br> load balancer .->service[Service];
  subgraph cluster
  service-->pod1[Pod];
  service-->pod2[Pod];
  end
  classDef plain fill:#ddd,stroke:#fff,stroke-width:4px,color:#000;
  classDef k8s fill:#326ce5,stroke:#fff,stroke-width:4px,color:#fff;
  classDef cluster fill:#fff,stroke:#bbb,stroke-width:2px,color:#326ce5;
  class ingress,service,pod1,pod2 k8s;
  class client plain;
  class cluster cluster;

```