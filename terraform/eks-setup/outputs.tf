output "eks_cluster_name" {
  description = "Name of the EKS cluster."
  value       = aws_eks_cluster.main.name
}

output "eks_cluster_endpoint" {
  description = "EKS Kubernetes API endpoint."
  value       = aws_eks_cluster.main.endpoint
}

output "eks_cluster_security_group_id" {
  description = "Primary EKS cluster security-group ID."
  value       = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}

output "eks_node_group_name" {
  description = "Name of the managed node group."
  value       = aws_eks_node_group.main.node_group_name
}

output "eks_node_role_arn" {
  description = "ARN of the worker-node IAM role."
  value       = aws_iam_role.eks_nodes.arn
}

output "eks_cluster_certificate_authority" {
  description = "Base64-encoded certificate-authority data for the EKS cluster."
  value       = aws_eks_cluster.main.certificate_authority[0].data
  sensitive   = true
}