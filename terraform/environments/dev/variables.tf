# Development Environment - Variables

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "emr-encryption"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

# Network Variables
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR block for private subnet"
  type        = string
}

variable "availability_zone" {
  description = "Availability zone for subnets"
  type        = string
}

# EMR Variables
variable "emr_release_label" {
  description = "EMR release version"
  type        = string
  default     = "emr-6.15.0"
}

variable "master_instance_type" {
  description = "EC2 instance type for master node"
  type        = string
  default     = "m5.xlarge"
}

variable "core_instance_type" {
  description = "EC2 instance type for core nodes"
  type        = string
  default     = "m5.xlarge"
}

variable "core_instance_count" {
  description = "Number of core instances"
  type        = number
  default     = 2
}

# Security Variables
variable "enable_encryption_at_rest" {
  description = "Enable encryption at rest"
  type        = bool
  default     = true
}

variable "enable_encryption_in_transit" {
  description = "Enable encryption in transit"
  type        = bool
  default     = true
}

variable "key_pair_name" {
  description = "EC2 key pair name for SSH access"
  type        = string
}

# Storage Variables
variable "enable_versioning" {
  description = "Enable versioning on S3 buckets"
  type        = bool
  default     = true
}

variable "enable_lifecycle_rules" {
  description = "Enable lifecycle rules on S3 buckets"
  type        = bool
  default     = true
}

variable "logs_expiration_days" {
  description = "Days until logs expire"
  type        = number
  default     = 90
}

variable "data_expiration_days" {
  description = "Days until data expires"
  type        = number
  default     = 180
}

# Auto-termination Variables
variable "auto_terminate" {
  description = "Enable auto-termination for cost savings"
  type        = bool
  default     = true
}

variable "idle_timeout_seconds" {
  description = "Idle timeout in seconds for auto-termination"
  type        = number
  default     = 3600
}

# Tags
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
