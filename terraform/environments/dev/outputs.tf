# Development Environment - Outputs

output "kms_key_id" {
  description = "KMS key ID"
  value       = module.kms.key_id
}

output "kms_key_arn" {
  description = "KMS key ARN"
  value       = module.kms.key_arn
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "private_subnet_id" {
  description = "Private subnet ID"
  value       = module.vpc.private_subnet_id
}

output "public_subnet_id" {
  description = "Public subnet ID"
  value       = module.vpc.public_subnet_id
}

output "logs_bucket_name" {
  description = "Logs bucket name"
  value       = module.s3.logs_bucket_name
}

output "data_bucket_name" {
  description = "Data bucket name"
  value       = module.s3.data_bucket_name
}

output "scripts_bucket_name" {
  description = "Scripts bucket name"
  value       = module.s3.scripts_bucket_name
}

# Additional outputs will be added as modules are implemented
# output "emr_cluster_id" {
#   description = "EMR cluster ID"
#   value       = module.emr.cluster_id
# }

# output "security_configuration_name" {
#   description = "EMR security configuration name"
#   value       = module.security_config.security_configuration_name
# }
