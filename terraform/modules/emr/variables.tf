variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "release_label" {
  description = "EMR release version"
  type        = string
  default     = "emr-6.15.0"
}

variable "applications" {
  description = "List of applications to install"
  type        = list(string)
  default     = ["Hadoop", "Spark", "Hive"]
}

variable "subnet_id" {
  description = "Subnet ID for EMR cluster"
  type        = string
}

variable "master_security_group_id" {
  description = "Security group ID for master node"
  type        = string
}

variable "slave_security_group_id" {
  description = "Security group ID for core/task nodes"
  type        = string
}

variable "service_role" {
  description = "IAM role ARN for EMR service"
  type        = string
}

variable "instance_profile" {
  description = "Instance profile ARN for EC2 instances"
  type        = string
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
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

variable "ebs_volume_size" {
  description = "EBS volume size in GB"
  type        = number
  default     = 32
}

variable "security_configuration" {
  description = "EMR security configuration name"
  type        = string
}

variable "logs_bucket" {
  description = "S3 bucket for logs"
  type        = string
}

variable "auto_terminate" {
  description = "Enable auto-termination"
  type        = bool
  default     = false
}

variable "idle_timeout_seconds" {
  description = "Idle timeout in seconds for auto-termination"
  type        = number
  default     = 3600
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
