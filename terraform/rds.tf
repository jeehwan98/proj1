# rds.tf - Managed PostgreSQL in the private subnet
# Only reachable by ECS (enforced by the RDS security group)

# Subnet group — tells RDS which subnets it can place instances in
# Requires at least 2 subnets in different AZs
# RDS needs to know which private subnets it can use. We pass both private subnets so AWS can place it across AZs
resource "aws_db_subnet_group" "main" {
  name       = "${local.name_prefix}-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id
  tags       = merge(local.common_tags, { Name = "${local.name_prefix}-db-subnet-group" })
}

resource "aws_db_instance" "main" {
  identifier = "${local.name_prefix}-postgres"

  engine         = "postgres"
  engine_version = "16"
  instance_class = var.db_instance_class

  db_name  = var.db_name
  username = var.db_username
  # Pulled directly from the secret Terraform so it's never written in plain text
  password = aws_secretsmanager_secret_version.db_password.secret_string

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  # No public endpoint — only reachable from within the VPC
  publicly_accessible = false

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp2"
  # Data at rest is encrypted
  storage_encrypted     = true

  # 0 = disabled (required for AWS free tier accounts)
  backup_retention_period = 0
  maintenance_window      = "mon:04:00-mon:05:00"

  deletion_protection = false

  # Final snapshot on destroy (ignored when deletion_protection = true anyway)
  skip_final_snapshot = true

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-postgres" })
}
