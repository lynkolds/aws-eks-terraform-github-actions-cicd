resource "aws_vpc_security_group_ingress_rule" "database_from_eks" {
  security_group_id = local.database_security_group_id

  description = "Allow MySQL access from the EKS cluster security group"

  referenced_security_group_id = (
    aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
  )

  from_port   = 3306
  to_port     = 3306
  ip_protocol = "tcp"
}