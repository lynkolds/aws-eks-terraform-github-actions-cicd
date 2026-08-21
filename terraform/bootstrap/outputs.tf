output "terraform_state_bucket_name" {
  description = "Name of the S3 bucket used for Terraform remote state."
  value       = aws_s3_bucket.terraform_state.bucket
}

output "terraform_state_bucket_arn" {
  description = "ARN of the S3 bucket used for Terraform remote state."
  value       = aws_s3_bucket.terraform_state.arn
}

# AWS_DEPLOYMENT_ROLE_ARN
output "github_deployment_role_arn" {
  description = "ARN of the IAM role assumed by GitHub Actions through OIDC."
  value       = aws_iam_role.github_deployment.arn
}