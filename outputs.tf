output "emr_cluster_id" {
  description = "ID of the EMR cluster"
  value       = aws_emr_cluster.secure_cluster.id
}

output "emr_cluster_name" {
  description = "Name of the EMR cluster"
  value       = aws_emr_cluster.secure_cluster.name
}

output "emr_cluster_master_public_dns" {
  description = "Master node public DNS name"
  value       = aws_emr_cluster.secure_cluster.master_public_dns
}

output "emr_security_configuration_name" {
  description = "Name of the EMR security configuration"
  value       = aws_emr_security_configuration.encryption_config.name
}

output "kms_key_id" {
  description = "ID of the KMS key used for encryption"
  value       = aws_kms_key.emr_encryption.id
}

output "kms_key_arn" {
  description = "ARN of the KMS key used for encryption"
  value       = aws_kms_key.emr_encryption.arn
}

output "certificates_bucket_name" {
  description = "Name of the S3 bucket storing PEM certificates"
  value       = aws_s3_bucket.certificates.id
}

output "logs_bucket_name" {
  description = "Name of the S3 bucket storing EMR logs"
  value       = aws_s3_bucket.logs.id
}

output "emr_service_role_arn" {
  description = "ARN of the EMR service role"
  value       = aws_iam_role.emr_service_role.arn
}

output "emr_ec2_instance_profile_arn" {
  description = "ARN of the EMR EC2 instance profile"
  value       = aws_iam_instance_profile.emr_ec2_instance_profile.arn
}

output "emr_autoscaling_role_arn" {
  description = "ARN of the EMR autoscaling role"
  value       = aws_iam_role.emr_autoscaling_role.arn
}
