CLUSTER_ROLE=AmazonEKSAutoClusterRole
NODE_ROLE=AmazonEKSAutoNodeRole

__detach_all_policies() {
  ROLE_NAME=$1
  POLICIES=$(
    aws iam list-attached-role-policies \
    --role-name $ROLE_NAME \
    --output json \
    | jq -r '.AttachedPolicies | map(.PolicyArn) | join("\n")'
  )
  echo "$POLICIES" | xargs -I {} echo "Detaching policy {} from role $ROLE_NAME"
  echo "$POLICIES" | xargs -I {} aws iam detach-role-policy --role-name $ROLE_NAME --policy-arn {}
}

__detach_all_policies $NODE_ROLE
aws iam delete-role --role-name $NODE_ROLE --output json | jq

__detach_all_policies $CLUSTER_ROLE
aws iam delete-role --role-name $CLUSTER_ROLE --output json | jq
