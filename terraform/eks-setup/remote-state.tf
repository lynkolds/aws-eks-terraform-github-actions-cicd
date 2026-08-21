data "terraform_remote_state" "foundation" {
  backend = "s3"

  config = {
    bucket = var.terraform_state_bucket
    key    = var.foundation_state_key
    region = var.aws_region
  }
}

locals {
  name_prefix = "${var.project_name}-${var.environment}"

  vpc_id = data.terraform_remote_state.foundation.outputs.vpc_id

  public_subnet_ids = (
    data.terraform_remote_state.foundation.outputs.public_subnet_ids
  )

  private_app_subnet_ids = (
    data.terraform_remote_state.foundation.outputs.private_app_subnet_ids
  )

  database_security_group_id = (
    data.terraform_remote_state.foundation.outputs.database_security_group_id
  )

  application_secret_arn = (
    data.terraform_remote_state.foundation.outputs.application_secret_arn
  )

  ecr_repository_url = (
    data.terraform_remote_state.foundation.outputs.ecr_repository_url
  )
}