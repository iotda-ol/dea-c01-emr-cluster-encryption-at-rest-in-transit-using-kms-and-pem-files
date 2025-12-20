variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "key_description" {
  description = "Description for the KMS key"
  type        = string
  default     = "KMS key for EMR cluster encryption"
}

variable "deletion_window_in_days" {
  description = "Duration in days after which the key is deleted after destruction"
  type        = number
  default     = 30
}

variable "enable_key_rotation" {
  description = "Enable automatic key rotation"
  type        = bool
  default     = true
}

variable "key_administrators" {
  description = "List of IAM ARNs that can administer the key"
  type        = list(string)
  default     = []
}

variable "key_users" {
  description = "List of IAM ARNs that can use the key"
  type        = list(string)
  default     = []
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
