variable "aws_region" {
  description = "AWS region for EMR cluster deployment"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "dea-c01-emr-secure"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "emr_release_label" {
  description = "EMR release version"
  type        = string
  default     = "emr-6.15.0"
}

variable "emr_master_instance_type" {
  description = "EC2 instance type for EMR master node"
  type        = string
  default     = "m5.xlarge"
}

variable "emr_core_instance_type" {
  description = "EC2 instance type for EMR core nodes"
  type        = string
  default     = "m5.xlarge"
}

variable "emr_core_instance_count" {
  description = "Number of EMR core instances"
  type        = number
  default     = 2
}

variable "subnet_id" {
  description = "Subnet ID for EMR cluster deployment"
  type        = string

  validation {
    condition     = can(regex("^subnet-[a-z0-9]+$", var.subnet_id))
    error_message = "Subnet ID must be a valid AWS subnet ID (e.g., subnet-12345678)."
  }
}

variable "vpc_id" {
  description = "VPC ID for EMR cluster deployment"
  type        = string

  validation {
    condition     = can(regex("^vpc-[a-z0-9]+$", var.vpc_id))
    error_message = "VPC ID must be a valid AWS VPC ID (e.g., vpc-12345678)."
  }
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access EMR cluster. Must be specified to enable SSH and HTTPS access. Example: ['10.0.0.0/8']. Avoid using 0.0.0.0/0 for security."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for cidr in var.allowed_cidr_blocks :
      can(cidrhost(cidr, 0))
    ])
    error_message = "All CIDR blocks must be valid CIDR notation (e.g., 10.0.0.0/8)."
  }
}

variable "key_name" {
  description = "EC2 key pair name for SSH access"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}

variable "enable_termination_protection" {
  description = "Enable termination protection for EMR cluster"
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "Number of days to retain logs in S3"
  type        = number
  default     = 90

  validation {
    condition     = var.log_retention_days > 0 && var.log_retention_days <= 3650
    error_message = "Log retention days must be between 1 and 3650 (10 years)."
  }
}

variable "certificate_s3_prefix" {
  description = "S3 prefix (folder) for the certificate bundle"
  type        = string
  default     = "certificates"
}
