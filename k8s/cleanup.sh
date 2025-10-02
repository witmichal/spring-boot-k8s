# cleanup
kubectl delete --all service -n test
kubectl delete --all deployment -n test
kubectl delete --all pod -n test
kubectl delete --all secret -n test
