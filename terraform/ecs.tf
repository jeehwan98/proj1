# ecs.tf - ECS Fargate cluster, task definitions, and services
# Fargate means AWS manages the underlying servers — you only define the containers.
/**
  Flow:
  1. ECR image → Task Definition (what to run) → Service (how many, where) → runs in private subnet
  2. ALB health-checks each task and routes traffic to healthy ones only
*/

resource "aws_ecs_cluster" "main" {
  name = "${local.name_prefix}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = local.common_tags
}

# CloudWatch log groups — one per service so logs are separated
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

# ── Backend Task Definition ────────────────────────────────────────────────────
# count = 0 when backend_image is empty (Phase 1 apply) — created in Phase 2 after docker push

resource "aws_ecs_task_definition" "backend" {
  count                    = var.backend_image != "" ? 1 : 0
  family                   = "${local.name_prefix}-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.backend_cpu
  memory                   = var.backend_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([{
    name      = "backend"
    image     = var.backend_image
    essential = true

    portMappings = [{
      containerPort = 8080
      protocol      = "tcp"
    }]

    environment = [
      { name = "SPRING_PROFILES_ACTIVE", value = "prod" },
      { name = "SPRING_DATASOURCE_URL",  value = "jdbc:postgresql://${aws_db_instance.main.address}:5432/${var.db_name}" },
      { name = "SPRING_DATASOURCE_USERNAME", value = var.db_username },
      { name = "REDIS_HOST", value = aws_elasticache_cluster.main.cache_nodes[0].address },
      { name = "REDIS_PORT", value = "6379" },
      { name = "APP_BASE_URL",        value = "https://${var.domain_name}" },
      { name = "OAUTH2_REDIRECT_URI", value = "https://${var.domain_name}" },
      { name = "SMTP_HOST",           value = var.smtp_host },
      { name = "SMTP_PORT",           value = tostring(var.smtp_port) },
    ]

    secrets = [
      { name = "SPRING_DATASOURCE_PASSWORD", valueFrom = aws_secretsmanager_secret.db_password.arn },
      { name = "JWT_SECRET",                 valueFrom = aws_secretsmanager_secret.jwt_secret.arn },
      { name = "SMTP_USERNAME",        valueFrom = aws_secretsmanager_secret.smtp_username.arn },
      { name = "SMTP_PASSWORD",        valueFrom = aws_secretsmanager_secret.smtp_password.arn },
      { name = "GITHUB_CLIENT_ID",     valueFrom = aws_secretsmanager_secret.github_client_id.arn },
      { name = "GITHUB_CLIENT_SECRET", valueFrom = aws_secretsmanager_secret.github_client_secret.arn },
      { name = "GOOGLE_CLIENT_ID",     valueFrom = aws_secretsmanager_secret.google_client_id.arn },
      { name = "GOOGLE_CLIENT_SECRET", valueFrom = aws_secretsmanager_secret.google_client_secret.arn },
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.backend.name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "backend"
      }
    }
  }])

  tags = local.common_tags
}

# ── Frontend Task Definition ───────────────────────────────────────────────────
# count = 0 when frontend_image is empty (Phase 1 apply) — created in Phase 2 after docker push

resource "aws_ecs_task_definition" "frontend" {
  count                    = var.frontend_image != "" ? 1 : 0
  family                   = "${local.name_prefix}-frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.frontend_cpu
  memory                   = var.frontend_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([{
    name      = "frontend"
    image     = var.frontend_image
    essential = true

    portMappings = [{
      containerPort = 3000
      protocol      = "tcp"
    }]

    environment = []

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.frontend.name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "frontend"
      }
    }
  }])

  tags = local.common_tags
}

# ── ECS Services ───────────────────────────────────────────────────────────────
# A service keeps the desired number of tasks running and re-registers them
# with the ALB target group so traffic is routed to healthy tasks only.

resource "aws_ecs_service" "backend" {
  count                              = var.backend_image != "" ? 1 : 0
  name                               = "${local.name_prefix}-backend"
  cluster                            = aws_ecs_cluster.main.id
  task_definition                    = aws_ecs_task_definition.backend[0].arn
  desired_count                      = 1
  launch_type                        = "FARGATE"
  health_check_grace_period_seconds  = 180

  network_configuration {
    subnets          = aws_subnet.private[*].id
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.backend.arn
    container_name   = "backend"
    container_port   = 8080
  }

  depends_on = [aws_lb_listener.https]

  tags = local.common_tags
}

resource "aws_ecs_service" "frontend" {
  count           = var.frontend_image != "" ? 1 : 0
  name            = "${local.name_prefix}-frontend"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.frontend[0].arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.private[*].id
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend.arn
    container_name   = "frontend"
    container_port   = 3000
  }

  depends_on = [aws_lb_listener.https]

  tags = local.common_tags
}
