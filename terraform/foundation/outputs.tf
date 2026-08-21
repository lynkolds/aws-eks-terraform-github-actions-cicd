# export the region
output "aws_region" {
  value = var.aws_region
}

# export the project name
output "project_name" {
  value = var.project_name
}

# export the environment
output "environment" {
  value = var.environment
}

# export the vpc id
output "vpc_id" {
  value = aws_vpc.vpc.id
}

# export the internet gateway
output "internet_gateway" {
  value = aws_internet_gateway.internet_gateway.id
}

#subnets
# export the public subnet az1 id
output "public_subnet_az1_id" {
  value = aws_subnet.public_subnet_az1.id
}

# export the public subnet az2 id
output "public_subnet_az2_id" {
  value = aws_subnet.public_subnet_az2.id
}

# Grouped output used by other Terraform roots.
output "public_subnet_ids" {
  description = "IDs of the public subnets."
  value = [aws_subnet.public_subnet_az1.id,
    aws_subnet.public_subnet_az2.id
  ]
}

# export the private app subnet az1 id
output "private_app_subnet_az1_id" {
  value = aws_subnet.private_app_subnet_az1.id
}

# export the private app subnet az2 id
output "private_app_subnet_az2_id" {
  value = aws_subnet.private_app_subnet_az2.id
}

# This is the main subnet output consumed by terraform/eks-setup. 
output "private_app_subnet_ids" {
  description = "IDs of the private application subnets used by EKS."
  value = [aws_subnet.private_app_subnet_az1.id,
    aws_subnet.private_app_subnet_az2.id
  ]
}

# export the private db subnet az1 id
output "private_db_subnet_az1_id" {
  value = aws_subnet.private_db_subnet_az1.id
}

# export the private db subnet az2 id
output "private_db_subnet_az2_id" {
  value = aws_subnet.private_db_subnet_az2.id
}

# Grouped database-subnet output. 
output "private_db_subnet_ids" {
  description = "IDs of the private database subnets."
  value = [aws_subnet.private_db_subnet_az1.id,
    aws_subnet.private_db_subnet_az2.id
  ]
}

# database

output "database_security_group_id" {
  description = "ID of the RDS security group."
  value       = aws_security_group.database_security_group.id
}

output "database_endpoint" {
  description = "RDS endpoint including its port."
  value       = aws_db_instance.database_instance.endpoint
}

output "database_address" {
  description = "RDS hostname without the port."
  value       = aws_db_instance.database_instance.address
}

output "database_port" {
  description = "RDS listener port."
  value       = aws_db_instance.database_instance.port
}

# ecr

output "ecr_repository_name" {
  description = "Name of the ECR application repository."
  value       = aws_ecr_repository.application.name
}

output "ecr_repository_url" {
  description = "URL of the ECR application repository."
  value       = aws_ecr_repository.application.repository_url
}

# secrets

output "application_secret_name" {
  description = "Name of the application Secrets Manager secret."
  value       = aws_secretsmanager_secret.application.name
}

output "application_secret_arn" {
  description = "ARN of the application Secrets Manager secret."
  value       = aws_secretsmanager_secret.application.arn
}