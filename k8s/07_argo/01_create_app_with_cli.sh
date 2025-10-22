argocd app create test \
--repo 'https://github.com/witmichal/spring-boot-k8s.git' \
--dest-namespace test \
--dest-server https://kubernetes.default.svc \
--path k8s/06_helm/helm-chart-demo