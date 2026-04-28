# elasticache.tf - Managed Redis in the private subnet
# Used by the backend for email verification codes and password reset codes

# Subnet group — tells ElastiCache which subnets it can place nodes in
resource "aws_elasticache_subnet_group" "main" {
  name       = "${local.name_prefix}-redis-subnet-group"
  subnet_ids = aws_subnet.private[*].id
  tags       = merge(local.common_tags, { Name = "${local.name_prefix}-redis-subnet-group" })
}

# Single-node Redis cluster (no replication — keeps cost low for a portfolio project)
resource "aws_elasticache_cluster" "main" {
  cluster_id           = "${local.name_prefix}-redis"
  engine               = "redis"
  engine_version       = "7.1"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  port                 = 6379

  subnet_group_name  = aws_elasticache_subnet_group.main.name
  security_group_ids = [aws_security_group.redis.id]

  # Automatic minor version upgrades during the maintenance window
  auto_minor_version_upgrade = true
  maintenance_window         = "mon:05:00-mon:06:00"

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-redis" })
}
