resource "aws_eks_addon" "metrics_server" {
  cluster_name = data.terraform_remote_state.eks.outputs.eks_cluster_name
  addon_name   = "metrics-server"
}