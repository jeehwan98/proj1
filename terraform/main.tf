# Main entry point
terraform {
  required_version = ">= 1.5"

  # Tells Terraform to download the AWS plugin
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  # instead of storing state locally, the state is saved to S3
  # this is implemented so that if we run Terraform from another machine or in CI/CD, everyone shared the same state
  backend "s3" {
    bucket  = "auth24-terraform-state"
    key     = "prod/terraform.tfstate"
    region  = "ap-southeast-1"
    encrypt = true
  }
}

provider "aws" {
  region = var.aws_region
}

# ACM certificates for CloudFront must be in us-east-1
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}
