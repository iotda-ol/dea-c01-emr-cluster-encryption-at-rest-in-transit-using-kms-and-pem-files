variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "kms_key_id" {
  description = "KMS key ID for encryption"
  type        = string
}

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

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
