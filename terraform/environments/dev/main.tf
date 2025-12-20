# Development Environment - Main Configuration

terraform {
  required_version = ">= 1.0.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  # Uncomment after creating S3 bucket and DynamoDB table for state
  # backend "s3" {
  #   bucket         = "emr-encryption-tfstate-ACCOUNT_ID"
  #   key            = "dev/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "emr-encryption-tfstate-lock"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.tags
  }
}

# Data source for current AWS account
data "aws_caller_identity" "current" {}

# Local variables
locals {
  account_id = data.aws_caller_identity.current.account_id
  common_tags = merge(
    var.tags,
    {
      Terraform   = "true"
      Environment = var.environment
    }
  )
}

# KMS Module - Encryption Keys
module "kms" {
  source = "../../modules/kms"

  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region
  
  key_description = "KMS key for ${var.project_name} ${var.environment} EMR cluster encryption"
  
  key_administrators = [
    "arn:aws:iam::${local.account_id}:root"
  ]
  
  # Note: These roles will be created below
  key_users = [
    "arn:aws:iam::${local.account_id}:role/${var.project_name}-${var.environment}-emr-service-role",
    "arn:aws:iam::${local.account_id}:role/${var.project_name}-${var.environment}-emr-ec2-role"
  ]

  tags = local.common_tags
}

# VPC Module - Network Infrastructure
module "vpc" {
  source = "../../modules/vpc"

  project_name = var.project_name
  environment  = var.environment
  
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  availability_zone   = var.availability_zone
  
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = local.common_tags
}

# S3 Module - Storage Buckets
module "s3" {
  source = "../../modules/s3"

  project_name = var.project_name
  environment  = var.environment
  
  kms_key_id = module.kms.key_id
  
  enable_versioning      = var.enable_versioning
  enable_lifecycle_rules = var.enable_lifecycle_rules
  logs_expiration_days   = var.logs_expiration_days
  data_expiration_days   = var.data_expiration_days
  
  tags = local.common_tags
  
  depends_on = [module.kms]
}

# Note: IAM roles, security configuration, and EMR cluster modules
# would be added here following the same pattern.
# See intermediate/steps-26-50.md for complete implementation.
