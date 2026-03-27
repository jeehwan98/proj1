# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${local.name_prefix}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = local.common_tags
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name       = aws_ecs_cluster.main.name
  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
  }
}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "backend" {
  name              = "/ecs/${local.name_prefix}/backend"
  retention_in_days = 30
  tags              = local.common_tags
}

resource "aws_cloudwatch_log_group" "frontend" {
  name              = "/ecs/${local.name_prefix}/frontend"
  retention_in_days = 30
  tags              = local.common_tags
}

# ECS Task Definition — backend + frontend containers
resource "aws_ecs_task_definition" "app" {
  family                   = "${local.name_prefix}-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.app_cpu
  memory                   = var.app_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  runtime_platform {
    cpu_architecture        = "ARM64"
    operating_system_family = "LINUX"
  }

  container_definitions = jsonencode([
    {
      name  = "backend"
      image = var.backend_image != "" ? var.backend_image : "${aws_ecr_repository.backend.repository_url}:latest"

      portMappings = [{
        containerPort = 8080
        protocol      = "tcp"
      }]

      environment = [
        { name = "DB_HOST",                  value = aws_db_instance.main.address },
        { name = "DB_PORT",                  value = "5432" },
        { name = "DB_USER",                  value = "postgres" },
        { name = "DB_NAME",                  value = "workplace" },
        { name = "SMTP_HOST",                value = "smtp.gmail.com" },
        { name = "SMTP_PORT",                value = "587" },
        { name = "SQS_QUEUE_URL",            value = aws_sqs_queue.invoice_email.url },
        { name = "MAX_EMAILS_PER_REQUEST",   value = "5" },
      ]

      secrets = [
        { name = "DB_PASSWORD",           valueFrom = aws_secretsmanager_secret.db_password.arn },
        { name = "SMTP_USER",             valueFrom = "${aws_secretsmanager_secret.smtp.arn}:user::" },
        { name = "SMTP_PASSWORD",         valueFrom = "${aws_secretsmanager_secret.smtp.arn}:password::" },
        { name = "GOOGLE_SA_JSON_CONTENT", valueFrom = aws_secretsmanager_secret.google_sa.arn },
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.backend.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    },
    {
      name  = "frontend"
      image = var.frontend_image != "" ? var.frontend_image : "${aws_ecr_repository.frontend.repository_url}:latest"

      portMappings = [{
        containerPort = 3000
        protocol      = "tcp"
      }]

      environment = [
        { name = "NEXT_PUBLIC_API_URL", value = "https://${var.domain_name}" },
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.frontend.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = local.common_tags
}

# ECS Service
resource "aws_ecs_service" "app" {
  name                   = "${local.name_prefix}-app"
  cluster                = aws_ecs_cluster.main.id
  task_definition        = aws_ecs_task_definition.app.arn
  desired_count          = 1
  launch_type            = "FARGATE"
  enable_execute_command = true

  network_configuration {
    subnets          = aws_subnet.private_ecs[*].id
    security_groups  = [aws_security_group.ecs_app.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "frontend"
    container_port   = 3000
  }

  depends_on = [aws_lb_listener.https]

  tags = local.common_tags
}
