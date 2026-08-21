locals {
  name_prefix = "${var.project_name}-${var.environment}"

  vpc_id = data.terraform_remote_state.foundation.outputs.vpc_id

  application_secret_arn = (
    data.terraform_remote_state.foundation.outputs.application_secret_arn
  )

  eks_cluster_name = (
    data.terraform_remote_state.eks.outputs.eks_cluster_name
  )

  eks_cluster_endpoint = (
    data.terraform_remote_state.eks.outputs.eks_cluster_endpoint
  )

  cluster_autoscaler_namespace       = var.cluster_autoscaler_namespace
  cluster_autoscaler_service_account = var.cluster_autoscaler_service_account

  # Update deliberately when the EKS Kubernetes version
  # is upgraded.

  cluster_autoscaler_image_tag     = var.cluster_autoscaler_image_tag
  cluster_autoscaler_chart_version = var.cluster_autoscaler_chart_version

  # Remove a trailing period if DOMAIN_NAME was entered as example.com.

  normalized_hosted_zone_name = trimsuffix(
    trimspace(var.hosted_zone_name),
    "."
  )
  # Accept either Z123456 or /hostedzone/Z123456. 
  normalized_hosted_zone_id = replace(
    trimspace(var.hosted_zone_id),
    "/hostedzone/",
    ""
  )
  # This value should remain stable for the life of the cluster. 

  external_dns_txt_owner_id = "${local.name_prefix}-external-dns"


}