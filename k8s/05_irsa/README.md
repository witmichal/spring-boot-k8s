# Get STS tokens from PODs

### AWS STS = AWS Security Token Service (AWS STS) is a web service that enables you to request temporary, limited-privilege credentials for users.

#### Enter the POD and check the 'aws' access
```shell
echo "POD name:\n\t aws-cli-no-authz VS aws-cli-no-authz"

kubectl exec -it aws-cli-no-authz -n test -- /bin/sh
aws s3api list-buckets
cat /var/run/secrets/kubernetes.io/serviceaccount/token
cat /var/run/secrets/eks.amazonaws.com/serviceaccount/token
```

#### Enter the POD and check the 'aws' access
```shell
kubectl exec -it aws-cli-authz -n test -- aws s3api list-buckets
kubectl exec -it aws-cli-authz -n test -- cat /var/run/secrets/kubernetes.io/serviceaccount/token | xargs python $(rr)/py/decode_jwt.py | jq
kubectl exec -it aws-cli-authz -n test -- cat /var/run/secrets/eks.amazonaws.com/serviceaccount/token | xargs python $(rr)/py/decode_jwt.py | jq

# if terminal prints results in a weird way:
python $(rr)/py/decode_jwt.py $(kubectl exec -it aws-cli-authz -n test -- cat /var/run/secrets/kubernetes.io/serviceaccount/token)
python $(rr)/py/decode_jwt.py $(kubectl exec -it aws-cli-authz -n test -- cat /var/run/secrets/eks.amazonaws.com/serviceaccount/token)
```

#### Decode 'iat' and 'exp'
```shell
kubectl exec -it aws-cli-authz -n test -- cat /var/run/secrets/kubernetes.io/serviceaccount/token \
| xargs python $(rr)/py/decode_jwt.py \
| jq '.iat, .exp' \
| xargs -I {} date -r {}

kubectl exec -it aws-cli-authz -n test -- cat /var/run/secrets/eks.amazonaws.com/serviceaccount/token \
| xargs python $(rr)/py/decode_jwt.py \
| jq '.iat, .exp' \
| xargs -I {} date -r {}

cat $AWS_ROLE_ARN
cat $AWS_WEB_IDENTITY_TOKEN_FILE
```
