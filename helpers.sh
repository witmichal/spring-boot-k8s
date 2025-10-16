#!/usr/bin/env bash

# shellcheck disable=SC2119
# shellcheck disable=SC2016
# shellcheck disable=SC2120
# shellcheck disable=SC2051
# shellcheck disable=SC2028

function blue_line() {
  BLUE='\033[0;34m'
  NC='\033[0m' # No Color

  NUMBER_OF_DASHES=${1:-10}
  pad=$(printf '%0.1s' "-"{1..$NUMBER_OF_DASHES})
  printf "${BLUE}${pad}${NC}"
}

function repo_root() {
  git rev-parse --show-toplevel
}
alias rr=repo_root

function provision_aws() {
  $(repo_root)/aws/create/all.sh
}

function cleanup_aws() {
  $(repo_root)/aws/cleanup/all.sh
}

function section_line() {
  LABEL_LENGTH_WITH_SPACES_AND_BRACKETS=$((${#1} + 4))
  LINE_LENGTH=$(((70 - ${LABEL_LENGTH_WITH_SPACES_AND_BRACKETS})/2))
  RED='\033[0;31m'
  BLUE='\033[0;34m'
  NC='\033[0m' # No Color
  LABEL="$(printf "%s [${RED}%s${NC}] %s" "$(blue_line $LINE_LENGTH)" "$1" "$(blue_line $LINE_LENGTH)")"
  echo "$LABEL"
}

function horizontal_line() {
  BLUE='\033[0;34m'
  NC='\033[0m' # No Color
  NUMBER_OF_DASHES=${1:-70}
  printf -- "${BLUE}-%.0s" {1.."$NUMBER_OF_DASHES"}; echo "${NC}"
}

function header() {
  GREEN='\033[0;32m'
  NC='\033[0m' # No Color
  echo "${GREEN}[$1] ${NC}$2"
}

function _cmd() {
  GREEN='\033[1;32m'
  NC='\033[0m' # No Color
  echo "\t ${GREEN}$1${NC}"
}

function source_helpers() {
  source $(git rev-parse --show-toplevel)/helpers.sh
}

function list_non_up_clusters() {
  kubectl config view --output json | jq '[.contexts[].name  | select(contains("minikube") or contains("eu-central-1"))]'
}

function get_personal_cluster_name() {
  list_non_up_clusters | jq -r 'map(select(contains("eu-central-1"))) | join("")'
}

function extract_document() {
  case $1 in
      Deployment|Service|Secret|Ingress) ;;
      *) echo "$1 kind not supported"; return 1 ;;
  esac
  SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
  cat "$SCRIPT_DIR"/resources.yaml | kind=$1 yq e '. | select(.kind == env(kind))'
}

function extract_document_by_name() {
  case $1 in
      Deployment|Service|Secret|Ingress) ;;
      *) echo "$1 kind not supported"; return 1 ;;
  esac
  if [ $# -lt 2 ] ; then
      echo "usage:"
      printf "e.g: \n\t extract_document_by_name Secret demo-b\n"
      return 1
  fi
  SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
  cat "$SCRIPT_DIR"/resources.yaml | kind=$1 name=$2 yq e '. | select(.kind == env(kind) and .metadata.name == env(name))'
}

function cleanup() {
  kubectl delete -f resources.yaml
}

function describe() {
  kubectl get all -n test
}

function describe_instances(){
  aws ec2 describe-instances --filters Name=instance-state-name,Values=running \
  | jq '.Reservations[].Instances[] | {s:.SubnetId,v:.VpcId,pr:.PrivateIpAddress,pu:.PublicIpAddress,id:.InstanceId,tag0value:.Tags[0].Value}'
}

function get_load_balancers(){
  aws elbv2 describe-load-balancers \
      | jq -r '.LoadBalancers'
}

function private_subnets(){
  python $(rr)/py/find_vpc_id_by_name.py "VpcWithTwoPublicSubnetsForEks-VPC" | xargs -I {} python $(rr)/py/find_private_subnets.py {}
}

function tmux_k8s_events_pods_and_logs() {
    if [ $# -lt 1 ] ; then
        echo "usage:"
        printf "\n\t tmux_k8s_events_pods_and_logs {resource}\n"
        printf "e.g: \n\t tmux_k8s_events_pods_and_logs pod/readiness-http\n"
        printf "e.g: \n\t tmux_k8s_events_pods_and_logs service/demo-a\n"
        return 1
    fi
    resource=$1

    # -d says not to attach to the session yet
    tmux new-session -d kubectl logs -f -n test "$resource"
    #tmux new-session -d watch -n 1 kubectl get pods -n test

    # In the most recently created session, split the (only) window
    tmux split-window -v watch -n 1 kubectl events -n test # 2 panels
    tmux resize-pane -D 12

    # Split the new pane
    tmux split-pane -h watch -n 1 kubectl get pods -n test #kubectl logs -f -n test pods/$pod_name on-failure-container # 3 panels

    tmux resize-pane -R 60
    tmux attach-session
 }

function help() {
  # misc
  section_line MISC
  header "MISC" "Display function body"
  _cmd 'declare -f describe'
  horizontal_line
  header "MISC" "Source helpers.sh"
  _cmd 'source_helpers'
  _cmd 'source $(git rev-parse --show-toplevel)/helpers.sh'
  # GIT
  section_line GIT
  header "MISC" "Display function body"
  _cmd 'git rev-parse --show-toplevel'
  # AWS
  section_line AWS
  header "AWS" "Get AWS account connection details"
  _cmd 'aws configure list'
  _cmd 'aws sts get-caller-identity --output json | jq'
  horizontal_line
  header "AWS" "Describe ec2 instances"
  _cmd 'describe_instances'
  horizontal_line
  header "AWS" "Get load balancers"
  _cmd 'get_load_balancers'
  _cmd "aws elbv2 describe-load-balancers | jq -r '.LoadBalancers'"
  horizontal_line
  header "AWS" "Get private subnets for custom VPC"
  _cmd 'private_subnets'
  # kubectl
  section_line kubectl
  header "kubectl" "Create k8s resources from STDIN (extracted from resources.yaml)"
  _cmd 'extract_document Deployment | kubectl create -f -'
  horizontal_line
  header "kubectl" "Current kubectl"
  _cmd 'kubectl config current-context'
  horizontal_line
  header "kubectl" "Get kubectl contexts"
  _cmd 'list_non_up_clusters'
  horizontal_line
  header "kubectl" "Use personal EKS cluster"
  _cmd 'kubectl config use-context $(get_personal_cluster_name)'
  horizontal_line
  header "kubectl" "Use minikube"
  _cmd 'kubectl config use-context minikube'
  horizontal_line
  header "kubectl" "Describe resources in test namespace"
  _cmd 'describe'
  _cmd 'kubectl get all -n test'
  horizontal_line
  header "kubectl" "Cleanup resources created from resources.yaml"
  _cmd 'cleanup'
  _cmd 'kubectl delete -f resources.yaml'
  # YAML
  section_line YAML
  header "YAML" "Extract document from file with documents with different kinds"
  _cmd 'extract_document Secret'
  horizontal_line
  header "YAML" "Extract document from file with multiple resources with same kind"
  _cmd 'extract_document_by_name Secret demo-b'
  # TMUX
  section_line TMUX
  header "TMUX" "Dashboard for POD exercises"
  _cmd 'tmux_k8s_events_pods_and_logs'
  horizontal_line
}
