SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

function provision_vpc_and_eks(){
 # source "$SCRIPT_DIR"/1_create_vpc.sh
  #source "$SCRIPT_DIR"/2_create_security_group.sh
  source "$SCRIPT_DIR"/3_create_eks_cluster.sh
  source "$SCRIPT_DIR"/4_create_bastion.sh
}

function provision_controllers(){
  source "$SCRIPT_DIR"/5_create_ingress_controller.sh
  #source "$SCRIPT_DIR"/6_install_aws_load_balancer_controller.sh
}

function provision_irsa(){
  source "$SCRIPT_DIR"/7_setup_irsa.sh
}

echo "Should \n1. VPN \n2. EKS \n3. bastion be provisioned \n[y/n]:"
read -s VPN_AND_EKS_AND_BASTION

echo "Should k8s controllers [ingress, aws load balancer] be provisioned [y/n]:"
read -s CONTROLLERS

echo "Should IRSA be setup [y/n]:"
read -s IRSA

case $VPN_AND_EKS_AND_BASTION in
    y) provision_vpc_and_eks ;;
    *) echo "Not provisioning VPN, EKS and bastion." ;;
esac

case $CONTROLLERS in
    y) provision_controllers ;;
    *) echo "Not provisioning controllers." ;;
esac

case $IRSA in
    y) provision_irsa ;;
    *) echo "Not provisioning controllers." ;;
esac
