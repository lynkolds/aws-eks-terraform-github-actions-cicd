data "terraform_remote_state" "foundation" {
  backend = "s3"

  config = {
    bucket = var.terraform_state_bucket
    key    = var.foundation_state_key
    region = var.aws_region
  }
}

data "terraform_remote_state" "eks" {
  backend = "s3"

  config = {
    bucket = var.terraform_state_bucket
    key    = var.eks_state_key
    region = var.aws_region
  }
}

