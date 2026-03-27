resource "aws_sqs_queue" "invoice_email" {
  name                       = "${local.name_prefix}-invoice-email"
  visibility_timeout_seconds = 300 # must be >= Lambda timeout
  message_retention_seconds  = 86400
  receive_wait_time_seconds  = 20 # long polling

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.invoice_email_dlq.arn
    maxReceiveCount     = 3
  })

  tags = local.common_tags
}

# Dead Letter Queue — stores messages that failed 3 times
resource "aws_sqs_queue" "invoice_email_dlq" {
  name                      = "${local.name_prefix}-invoice-email-dlq"
  message_retention_seconds = 1209600 # 14 days

  tags = local.common_tags
}
