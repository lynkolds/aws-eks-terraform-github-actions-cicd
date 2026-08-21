# Installs the EKS Pod Identity Agent as an EKS-managed add-on.
#
# The agent runs on the worker nodes and supplies temporary IAM
# credentials to Pods that have Pod Identity associations.
resource "aws_eks_addon" "pod_identity_agent" {
  cluster_name = local.eks_cluster_name
  addon_name   = "eks-pod-identity-agent"

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  tags = {
    Name = "${local.name_prefix}-pod-identity-agent"
  }
}