terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = merge(
      {
        Project     = var.project_name
        Environment = var.environment
        ManagedBy   = "Terraform"
        Purpose     = "EMR Cluster with Encryption"
      },
      var.tags
    )
  }
}

# Data source for current AWS account
data "aws_caller_identity" "current" {}

# Data source for AWS partition
data "aws_partition" "current" {}
