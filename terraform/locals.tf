# Computed constraints - we write it once and reference it everywhere
locals {
  name_prefix = "${var.project}-${var.environment}"

  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  }

  # Availability zones — use the first two in the region
  azs = ["${var.aws_region}a", "${var.aws_region}b"]

  # Subnet CIDRs carved out of var.vpc_cidr (10.0.0.0/16)
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
}
