SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

echo "Should whole infra be cleaned up [y/n]:"
read -s mainmenuinput
case $mainmenuinput in
    y) ;;
    *) echo "Not cleaning up anything."; exit 0 ;;
esac

source "$SCRIPT_DIR"/cleanup_0_bastions.sh
source "$SCRIPT_DIR"/cleanup_1_iam_roles.sh
source "$SCRIPT_DIR"/cleanup_2_security_groups.sh
source "$SCRIPT_DIR"/cleanup_3_eks_cluster.sh
