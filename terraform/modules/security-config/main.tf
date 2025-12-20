# EMR Security Configuration Module

resource "aws_emr_security_configuration" "main" {
  name = "${var.project_name}-${var.environment}-security-config"

  configuration = jsonencode({
    EncryptionConfiguration = {
      EnableInTransitEncryption = var.enable_in_transit_encryption
      EnableAtRestEncryption    = var.enable_at_rest_encryption
      
      InTransitEncryptionConfiguration = var.enable_in_transit_encryption ? {
        TLSCertificateConfiguration = {
          CertificateProviderType = "PEM"
          S3Object                = "s3://${var.certificates_s3_bucket}/${var.certificates_s3_prefix}"
        }
      } : null
      
      AtRestEncryptionConfiguration = var.enable_at_rest_encryption ? {
        S3EncryptionConfiguration = {
          EncryptionMode = "SSE-KMS"
          AwsKmsKey      = var.kms_key_id
        }
        LocalDiskEncryptionConfiguration = {
          EncryptionKeyProviderType = "AwsKms"
          AwsKmsKey                = var.kms_key_id
          EnableEbsEncryption      = true
        }
      } : null
    }
  })
}
