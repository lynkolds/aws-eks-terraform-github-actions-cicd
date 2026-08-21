variable "aws_region" {
  description = "AWS Region used by the project."
  type        = string
}

variable "project_name" {
  description = "Project name used in resource names."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "terraform_state_bucket" {
  description = "S3 bucket containing the Terraform state files."
  type        = string
}

variable "foundation_state_key" {
  description = "S3 key containing the foundation Terraform state."
  type        = string
}

variable "eks_state_key" {
  description = "S3 key containing the EKS Terraform state."
  type        = string
}

variable "application_namespace" {
  description = "Kubernetes namespace used by the application."
  type        = string
  default     = "application"
}

variable "application_service_account" {
  description = "Kubernetes service account used by the application."
  type        = string
  default     = "application-service-account"
}


variable "hosted_zone_name" {
  description = "Route 53 hosted zone domain managed by ExternalDNS."
  type        = string
}

variable "hosted_zone_id" {
  description = "ID of the existing Route 53 hosted zone containing the application domain."
  type        = string

  validation {
    condition     = trimspace(var.hosted_zone_id) != ""
    error_message = "hosted_zone_id must not be empty."
  }
}

variable "external_dns_chart_version" {
  description = "Pinned version of the official ExternalDNS Helm chart."
  type        = string
  default     = "1.21.1"
}

variable "external_dns_namespace" {
  description = "Kubernetes namespace used by ExternalDNS."
  type        = string
  default     = "external-dns"
}

variable "external_dns_service_account" {
  description = "Kubernetes service account used by ExternalDNS."
  type        = string
  default     = "external-dns"
}

variable "sns_email" {
  description = "Shared email address that receives EKS CloudWatch alarm notifications."
  type        = string

  validation {
    condition     = can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", var.sns_email))
    error_message = "sns_email must contain a valid email address."
  }
}

variable "cloudwatch_observability_addon_version" {
  description = "Pinned Amazon CloudWatch Observability EKS add-on version compatible with the cluster Kubernetes version."
  type        = string

  validation {
    condition     = trimspace(var.cloudwatch_observability_addon_version) != ""
    error_message = "cloudwatch_observability_addon_version must not be empty."
  }
}

variable "eks_node_cpu_alarm_threshold" {
  description = "Average EKS node CPU-utilization percentage that triggers an alarm."
  type        = number
  default     = 80
}

variable "eks_node_memory_alarm_threshold" {
  description = "Average EKS node memory-utilization percentage that triggers an alarm."
  type        = number
  default     = 80
}

variable "eks_node_filesystem_alarm_threshold" {
  description = "Average EKS node filesystem-utilization percentage that triggers an alarm."
  type        = number
  default     = 80
}

variable "minimum_healthy_eks_node_count" {
  description = "Minimum number of worker nodes expected to remain available."
  type        = number
  default     = 1

  validation {
    condition     = var.minimum_healthy_eks_node_count >= 1
    error_message = "minimum_healthy_eks_node_count must be at least 1."
  }
}

variable "cluster_autoscaler_namespace" {
  description = "Kubernetes namespace used by the Cluster Autoscaler."
  type        = string
  default     = "kube-system"
}

variable "cluster_autoscaler_service_account" {
  description = "Kubernetes service account used by the Cluster Autoscaler."
  type        = string
  default     = "cluster-autoscaler"
}

variable "cluster_autoscaler_image_tag" {
  description = "Pinned version of the official Cluster Autoscaler Docker image."
  type        = string
  default     = "v1.35.2"
}
variable "cluster_autoscaler_chart_version" {
  description = "Pinned version of the Cluster Autoscaler Helm chart."
  type        = string
  default     = "9.59.0"
}