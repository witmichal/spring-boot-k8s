# cleanup
kubectl get service -n test -ojsonpath='{.items}' | jq '{services: [{name: .[].metadata.name}]}'
kubectl get deployments -n test -ojsonpath='{.items}' | jq '{deployments: [{name: .[].metadata.name}]}'
kubectl get pod -n test -ojsonpath='{.items}' | jq '{pods: [{name: .[].metadata.name}]}'
kubectl get secret -n test -ojsonpath='{.items}' | jq '{secrets: [{name: .[].metadata.name}]}'
