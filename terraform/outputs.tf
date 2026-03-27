output "alb_dns_name" {
  description = "ALB DNS — point your domain CNAME to this"
  value       = aws_lb.main.dns_name
}

output "acm_dns_validation_records" {
  description = "Add these CNAME records to your DNS to validate the SSL certificate"
  value = {
    for dvo in aws_acm_certificate.main.domain_validation_options : dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }
}

output "ecr_backend_url" {
  description = "Backend ECR repository URL"
  value       = aws_ecr_repository.backend.repository_url
}

output "ecr_frontend_url" {
  description = "Frontend ECR repository URL"
  value       = aws_ecr_repository.frontend.repository_url
}

output "ecr_lambda_url" {
  description = "Lambda ECR repository URL"
  value       = aws_ecr_repository.lambda_email_sender.repository_url
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.main.name
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.main.address
  sensitive   = true
}

output "sqs_queue_url" {
  description = "SQS invoice email queue URL"
  value       = aws_sqs_queue.invoice_email.url
}
