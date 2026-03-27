variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "ap-southeast-1"
}

variable "app_name" {
  description = "Application Name"
  type        = string
  default     = "jee"
}

variable "environment" {
  description = "Environment"
  type        = string
  default     = "prod"
}

variable "domain_name" {
  description = "domain"
  type        = string

}

variable "google_client_id" {
  description = "Google OAuth 2.0 Client ID"
  type        = string
  sensitive   = true
}

variable "google_client_secret" {
  description = "Google OAuth 2.0 Client Secret"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "RDS Instance Class"
  type        = string
  default     = "db.t3.micro"
}

variable "smtp_user" {
  description = "Gmail STMP Account"
  type        = string
  sensitive   = true
}

variable "smtp_password" {
  description = "Gmail App Password"
  type        = string
  sensitive   = true
}

variable "google_service_account_json" {
  description = "Google Service Account JSON entire content"
  type        = string
  sensitive   = true
}

variable "app_cpu" {
  description = "App ECS CPU unit"
  type        = number
  default     = 1024
}

variable "app_memory" {
  description = "value"
  type        = number
  default     = 2048
}

variable "backend_image" {
  description = "Backend ECR Image URI (if left empty, the default ECR URL would be used)"
  type        = string
  default     = ""
}

variable "frontend_image" {
  description = "Frontend ECR Image URI (if left empty, the default ECR URL would be used)"
  type        = string
  default     = ""
}

variable "lambda_email_sender_image" {
  description = "Lambda email sender ECR Image URI (if left empty, the default ECR URL would be used)"
  type        = string
  default     = ""
}
