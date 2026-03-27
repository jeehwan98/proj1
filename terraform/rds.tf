resource "random_password" "db_password" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_db_subnet_group" "main" {
  name       = "${local.name_prefix}-db-subnet-group"
  subnet_ids = aws_subnet.private_rds[*].id

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-db-subnet-group" })
}

resource "aws_db_instance" "main" {
  identifier = "${local.name_prefix}-postgres"

  engine         = "postgres"
  engine_version = "16"
  instance_class = var.db_instance_class

  db_name  = "workplace"
  username = "postgres"
  password = random_password.db_password.result

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp3"
  storage_encrypted     = true

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  multi_az            = false
  publicly_accessible = false

  backup_retention_period  = 7
  backup_window            = "03:00-04:00"
  maintenance_window       = "Mon:04:00-Mon:05:00"
  delete_automated_backups = false

  skip_final_snapshot       = false
  final_snapshot_identifier = "${local.name_prefix}-final-snapshot"
  deletion_protection       = true

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-postgres" })
}
