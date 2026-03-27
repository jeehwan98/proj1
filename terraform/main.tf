terraform {
  required_version = ">= 1.5"

  required_providers {

  }

  backend "s3" {
    bucket  = "jee-terraform-state"
    key     = "prod/terraform.tfstate"
    region  = "ap-southeast-1"
    encrypt = true
  }
}

provider "aws" {
  region = var.aws_region
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}
