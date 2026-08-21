# Creates the security group attached to the RDS database.
#
# At this stage, no MySQL ingress rule is added because the EKS
# cluster and its security group do not exist yet.
resource "aws_security_group" "database_security_group" {
  name        = "${local.name_prefix}-database-sg"
  description = "Security group for the RDS database"
  vpc_id      = aws_vpc.vpc.id

  # Allows outbound traffic from the database security group.
  egress {
    description = "Allow all outbound IPv4 traffic"

    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_prefix}-database-sg"
  }
}