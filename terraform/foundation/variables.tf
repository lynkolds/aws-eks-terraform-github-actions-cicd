# Global variables
variable "aws_region" {
  description = "AWS region to deploy resources in"
}

variable "project_name" {
  description = "Project name used in resource names"
}

variable "environment" {
  description = "Deployment environment (e.g., dev, prod)"
}

# VPC networking
variable "vpc_cidr" {}

variable "public_subnet_az1_cidr" {}
variable "public_subnet_az2_cidr" {}

variable "private_app_subnet_az1_cidr" {}
variable "private_app_subnet_az2_cidr" {}

variable "private_db_subnet_az1_cidr" {}
variable "private_db_subnet_az2_cidr" {}


# Database (RDS)
variable "database_snapshot_identifier" {}
variable "database_instance_class" {}
variable "database_instance_identifier" {}
variable "multi_az_deployment" {}



# ECR

variable "image_tag_mutability" {}
variable "scan_on_push" {}
variable "force_delete" {}
variable "enable_lifecycle_policy" {}
variable "lifecycle_keep_last_n" {}

# Secrets
variable "secrets_recovery_window_days" {
  description = "Number of days to retain a secret in the recovery window before permanent deletion."
  type        = number
  default     = 7
}





