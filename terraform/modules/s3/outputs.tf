output "logs_bucket_id" {
  description = "Logs bucket ID"
  value       = aws_s3_bucket.logs.id
}

output "logs_bucket_name" {
  description = "Logs bucket name"
  value       = aws_s3_bucket.logs.bucket
}

output "logs_bucket_arn" {
  description = "Logs bucket ARN"
  value       = aws_s3_bucket.logs.arn
}

output "data_bucket_id" {
  description = "Data bucket ID"
  value       = aws_s3_bucket.data.id
}

output "data_bucket_name" {
  description = "Data bucket name"
  value       = aws_s3_bucket.data.bucket
}

output "data_bucket_arn" {
  description = "Data bucket ARN"
  value       = aws_s3_bucket.data.arn
}

output "scripts_bucket_id" {
  description = "Scripts bucket ID"
  value       = aws_s3_bucket.scripts.id
}

output "scripts_bucket_name" {
  description = "Scripts bucket name"
  value       = aws_s3_bucket.scripts.bucket
}

output "scripts_bucket_arn" {
  description = "Scripts bucket ARN"
  value       = aws_s3_bucket.scripts.arn
}
