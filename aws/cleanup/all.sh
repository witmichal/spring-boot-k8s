SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

source "$SCRIPT_DIR"/cleanup_0_bastions.sh
source "$SCRIPT_DIR"/cleanup_1_iam_roles.sh
source "$SCRIPT_DIR"/cleanup_2_security_groups.sh
source "$SCRIPT_DIR"/cleanup_3_eks_cluster_and_vpc.sh
