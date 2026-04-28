# iam.tf - Two IAM roles for ECS
/**
  Task Execution Role — used by the ECS AGENT (AWS infrastructure), not your app code
  - Pull Docker images from ECR
  - Write logs to CloudWatch
  - Fetch secrets from Secrets Manager at container startup

  Task Role — used by your APP CODE running inside the container
  - Only needed if your app calls AWS services directly (S3, SQS, etc.)
  - Empty for now but created so it's ready if needed later
*/

# Task Execution Role

resource "aws_iam_role" "ecs_task_execution" {
  name = "${local.name_prefix}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = local.common_tags
}

# AWS managed policy — covers ECR pulls and CloudWatch Logs
resource "aws_iam_role_policy_attachment" "ecs_task_execution_managed" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Extra inline policy — allows fetching our specific secrets from Secrets Manager
resource "aws_iam_role_policy" "ecs_task_execution_secrets" {
  name = "read-secrets"
  role = aws_iam_role.ecs_task_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ]
      Resource = [
        aws_secretsmanager_secret.db_password.arn,
        aws_secretsmanager_secret.jwt_secret.arn,
        aws_secretsmanager_secret.smtp.arn,
        aws_secretsmanager_secret.github_oauth.arn,
        aws_secretsmanager_secret.google_oauth.arn,
      ]
    }]
  })
}

# Task Role
resource "aws_iam_role" "ecs_task" {
  name = "${local.name_prefix}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = local.common_tags
}
