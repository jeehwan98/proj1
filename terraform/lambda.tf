# CloudWatch Log Group for Lambda
resource "aws_cloudwatch_log_group" "lambda_email_sender" {
  name              = "/aws/lambda/${local.name_prefix}-email-sender"
  retention_in_days = 30
  tags              = local.common_tags
}

# Lambda IAM Role
resource "aws_iam_role" "lambda_email_sender" {
  name = "${local.name_prefix}-lambda-email-sender"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
  role       = aws_iam_role.lambda_email_sender.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy" "lambda_sqs_consume" {
  name = "${local.name_prefix}-lambda-sqs-consume"
  role = aws_iam_role.lambda_email_sender.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:ChangeMessageVisibility",
        ]
        Resource = [
          aws_sqs_queue.invoice_email.arn,
          aws_sqs_queue.invoice_email_dlq.arn,
        ]
      },
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = [
          aws_secretsmanager_secret.smtp.arn,
          aws_secretsmanager_secret.db_password.arn,
        ]
      },
    ]
  })
}

# Lambda Security Group
resource "aws_security_group" "lambda_email_sender" {
  name        = "${local.name_prefix}-sg-lambda-email-sender"
  description = "Lambda email sender - RDS access + outbound SMTP"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-sg-lambda-email-sender" })
}

# Lambda Function
resource "aws_lambda_function" "email_sender" {
  function_name = "${local.name_prefix}-email-sender"
  role          = aws_iam_role.lambda_email_sender.arn
  package_type  = "Image"
  image_uri     = var.lambda_email_sender_image != "" ? var.lambda_email_sender_image : "${aws_ecr_repository.lambda_email_sender.repository_url}:latest"

  architectures = ["arm64"]
  timeout       = 300
  memory_size   = 1024

  vpc_config {
    subnet_ids         = aws_subnet.private_ecs[*].id
    security_group_ids = [aws_security_group.lambda_email_sender.id]
  }

  environment {
    variables = {
      DB_HOST         = aws_db_instance.main.address
      DB_PORT         = "5432"
      DB_USER         = "postgres"
      DB_NAME         = "workplace"
      SMTP_HOST       = "smtp.gmail.com"
      SMTP_PORT       = "587"
      SMTP_SECRET_ARN = aws_secretsmanager_secret.smtp.arn
      DB_SECRET_ARN   = aws_secretsmanager_secret.db_password.arn
    }
  }

  depends_on = [aws_cloudwatch_log_group.lambda_email_sender]

  tags = local.common_tags
}

# SQS → Lambda trigger
resource "aws_lambda_event_source_mapping" "sqs_to_email_sender" {
  event_source_arn = aws_sqs_queue.invoice_email.arn
  function_name    = aws_lambda_function.email_sender.arn

  batch_size                         = 10
  maximum_batching_window_in_seconds = 5
  function_response_types            = ["ReportBatchItemFailures"]

  scaling_config {
    maximum_concurrency = 5
  }
}
