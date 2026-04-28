# Defines everything that can vary between environments or that shouldn't be harcoded
# sensitive = true - means Terraform won't print their values in terminal output
# backend_image and frontend_image - start as empty - we fill them in after we build and push our Docker images to ECR for the first time
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "project" {
  description = "Project name used in resource naming"
  type        = string
  default     = "auth24"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "prod"
}

variable "domain_name" {
  description = "Root domain name"
  type        = string
  default     = "authentication24.com"
}

# VPC
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# RDS
variable "db_name" {
  description = "PostgreSQL database name"
  type        = string
  default     = "auth24db"
}

variable "db_username" {
  description = "PostgreSQL master username"
  type        = string
  default     = "auth24user"
}

variable "db_instance_class" {
  description = "RDS instance type"
  type        = string
  default     = "db.t3.micro"
}

# ECS
variable "backend_image" {
  description = "Full ECR image URI for the backend (set after first docker push)"
  type        = string
  default     = ""
}

variable "frontend_image" {
  description = "Full ECR image URI for the frontend (set after first docker push)"
  type        = string
  default     = ""
}

variable "backend_cpu" {
  description = "CPU units for the backend container"
  type        = number
  default     = 256
}

variable "backend_memory" {
  description = "Memory (MB) for the backend container"
  type        = number
  default     = 512
}

variable "frontend_cpu" {
  description = "CPU units for the frontend container"
  type        = number
  default     = 256
}

variable "frontend_memory" {
  description = "Memory (MB) for the frontend container"
  type        = number
  default     = 512
}

# Email (SMTP for password reset)
variable "smtp_host" {
  description = "SMTP host"
  type        = string
  default     = "smtp.gmail.com"
}

variable "smtp_port" {
  description = "SMTP port"
  type        = number
  default     = 587
}

variable "smtp_username" {
  description = "SMTP username (email address)"
  type        = string
  sensitive   = true
}

variable "smtp_password" {
  description = "SMTP password or app password"
  type        = string
  sensitive   = true
}

# OAuth2
variable "github_client_id" {
  description = "GitHub OAuth2 client ID"
  type        = string
  sensitive   = true
}

variable "github_client_secret" {
  description = "GitHub OAuth2 client secret"
  type        = string
  sensitive   = true
}

variable "google_client_id" {
  description = "Google OAuth2 client ID"
  type        = string
  sensitive   = true
}

variable "google_client_secret" {
  description = "Google OAuth2 client secret"
  type        = string
  sensitive   = true
}
