function help() {
  echo "Create k8s resources from STDIN (extracted from resources.yaml)"
  echo "extract_resources Deployment | kubectl create -f -"
}

function extract_resources() {
  case $1 in
      Deployment|Service|Secret|Ingress) ;;
      *) echo "$1 kind not supported"; return 1 ;;
  esac
  cat resources.yaml | kind=$1 yq e '. | select(.kind == env(kind))'
}
