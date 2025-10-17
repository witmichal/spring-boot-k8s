# 01
```shell
# create
k create -f 01_resources_one_container_lifecycle_failing.yaml

# test
watch -n 1 kubectl get pods -n test

#cleanup
k delete ns test
```

# 02
```shell
# create
k create -f 02_resources_one_container_lifecycle_succeeded.yaml

# test
watch -n 1 kubectl get pods -n test

#cleanup
k delete ns test
```


# 03
```shell
# create
k create -f 03_container_probes.yaml

# test
watch -n 1 kubectl events -n test

#cleanup
k delete ns test
```

# 04
```shell
# create
k create -f 04_container_probes_http.yaml

# test
watch -n 1 kubectl events -n test

#cleanup
k delete ns test
```


# 05
```shell
# create
k create -f 05_container_readiness_probe.yaml

# test
watch -n 1 kubectl events -n test

#cleanup
k delete ns test
```
