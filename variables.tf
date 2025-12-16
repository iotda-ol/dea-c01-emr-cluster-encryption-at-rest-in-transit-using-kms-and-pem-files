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
}

variable "vpc_id" {
  description = "VPC ID for EMR cluster deployment"
  type        = string
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access EMR cluster"
  type        = list(string)
  default     = []
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
}
