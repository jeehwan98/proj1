# security_groups.tf - virtual firewalls that control which traffic can flow between resources
/**
  Internet                                                                           
    │ 80/443
    ▼                                                                                
  [ ALB SG ]                                                
    │ any port                                                                       
    ▼                                                                                
  [ ECS SG ] ──────outbound──────▶ ECR / SMTP / internet
    │ 5432          │ 6379                                                           
    ▼               ▼                                       
  [ RDS SG ]    [ Redis SG ]

  Key principle: RDS and Redis have no public ingress at all - the only thing that can reach them is ECS, and ECS
  can only be reached from the ALB. Nothing in the private subnet is directly reachable from the internet
*/

# ALB — accepts HTTP/HTTPS from the internet
resource "aws_security_group" "alb" {
  name        = "${local.name_prefix}-sg-alb"
  description = "Allow HTTP and HTTPS from the internet"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-sg-alb" })
}

# ECS — accepts traffic from ALB only; needs outbound for ECR pulls and SMTP
resource "aws_security_group" "ecs" {
  name        = "${local.name_prefix}-sg-ecs"
  description = "Allow inbound from ALB only"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "From ALB"
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-sg-ecs" })
}

# RDS — accepts PostgreSQL from ECS only
resource "aws_security_group" "rds" {
  name        = "${local.name_prefix}-sg-rds"
  description = "Allow PostgreSQL from ECS only"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "PostgreSQL from ECS"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-sg-rds" })
}

# Redis — accepts Redis port from ECS only
resource "aws_security_group" "redis" {
  name        = "${local.name_prefix}-sg-redis"
  description = "Allow Redis from ECS only"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Redis from ECS"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-sg-redis" })
}
