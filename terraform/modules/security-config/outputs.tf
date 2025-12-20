output "security_configuration_name" {
  description = "Name of the EMR security configuration"
  value       = aws_emr_security_configuration.main.name
}

output "security_configuration_id" {
  description = "ID of the EMR security configuration"
  value       = aws_emr_security_configuration.main.id
}
