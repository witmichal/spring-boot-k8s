
```shell
echo "to communicate with LoadBalancer service, run (from within EC2 instance in the same VPN)
:"
curl <DNS-of-created-load-balancer>:<spec.ports.port>

echo "E.G."
curl k8s-test-demoa-51d794a2b3-af7daa31cbb4c67b.elb.eu-central-1.amazonaws.com:8888
```