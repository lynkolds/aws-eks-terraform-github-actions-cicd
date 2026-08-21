variable "aws_region" {
  description = "AWS Region where the Terraform state bucket will be created."
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "Named AWS CLI profile used for the local bootstrap deployment."
  type        = string
}

variable "project_name" {
  description = "Name of the project."
  type        = string
}

variable "environment" {
  description = "Deployment environment, such as dev or prod."
  type        = string
}

variable "github_owner" {
  description = "GitHub username or organization that owns the repository."
  type        = string
}

variable "github_owner_id" {
  description = "GitHub user or organization ID that owns the repository."
  type        = string
}

variable "github_repository" {
  description = "GitHub repository allowed to assume the deployment IAM role."
  type        = string
}

variable "github_repository_id" {
  description = "GitHub repository ID allowed to assume the deployment IAM role."
  type        = string
}


variable "github_environment_name" {
  description = "GitHub Environment permitted to assume the AWS role."
  type        = string
}