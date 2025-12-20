variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "enable_at_rest_encryption" {
  description = "Enable encryption at rest"
  type        = bool
  default     = true
}

variable "enable_in_transit_encryption" {
  description = "Enable encryption in transit"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMS key ID for encryption"
  type        = string
}

variable "certificates_s3_bucket" {
  description = "S3 bucket containing certificates"
  type        = string
}

variable "certificates_s3_prefix" {
  description = "S3 prefix for certificates"
  type        = string
  default     = "certificates/"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
