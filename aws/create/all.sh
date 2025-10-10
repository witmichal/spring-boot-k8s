SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

source "$SCRIPT_DIR"/1_create_vpc.sh
source "$SCRIPT_DIR"/2_create_security_group.sh
source "$SCRIPT_DIR"/3_create_eks_iam.sh
source "$SCRIPT_DIR"/4_create_eks_cluster.sh
source "$SCRIPT_DIR"/5_create_bastion.sh
source "$SCRIPT_DIR"/6_install_aws_load_balancer_controller.sh
