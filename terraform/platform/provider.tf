provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

data "aws_eks_cluster_auth" "main" {
  name = local.eks_cluster_name
}

provider "kubernetes" {
  host = local.eks_cluster_endpoint

  cluster_ca_certificate = base64decode(
    data.terraform_remote_state.eks.outputs.eks_cluster_certificate_authority
  )

  token = data.aws_eks_cluster_auth.main.token
}

provider "helm" {
  kubernetes = {
    host = local.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(
      data.terraform_remote_state.eks.outputs.eks_cluster_certificate_authority
    )

    token = data.aws_eks_cluster_auth.main.token
  }
}