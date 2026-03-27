# ALB — allow HTTP/HTTPS from internet
resource "aws_security_group" "alb" {
  name        = "${local.name_prefix}-sg-alb"
  description = "ALB - allow HTTP/HTTPS from internet"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
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

# ECS — allow traffic from ALB only
resource "aws_security_group" "ecs_app" {
  name        = "${local.name_prefix}-sg-ecs-app"
  description = "ECS app - allow port 3000 from ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-sg-ecs-app" })
}

# RDS — allow port 5432 from ECS and Lambda only
resource "aws_security_group" "rds" {
  name        = "${local.name_prefix}-sg-rds"
  description = "RDS - allow 5432 from ECS and Lambda"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_app.id]
  }

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.lambda_email_sender.id]
  }

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-sg-rds" })
}
