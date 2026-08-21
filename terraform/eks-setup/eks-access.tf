# Creates an EKS access entry for the IAM role used by GitHub Actions.
#
# This tells EKS that the GitHub deployment role is allowed to
# authenticate to the Kubernetes API.
resource "aws_eks_access_entry" "github_deployment" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = var.github_deployment_role_arn
  type          = "STANDARD"
}

# Associates an EKS access policy with the GitHub deployment role.
#
# The access entry above allows the IAM role to authenticate.
# This resource defines what the role may do inside Kubernetes.

resource "aws_eks_access_policy_association" "github_cluster_admin" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = var.github_deployment_role_arn

  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [
    aws_eks_access_entry.github_deployment
  ]
}