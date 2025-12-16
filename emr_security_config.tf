# EMR Security Configuration with Encryption at Rest and In Transit
resource "aws_emr_security_configuration" "encryption_config" {
  name = "${var.project_name}-${var.environment}-security-config"

  configuration = jsonencode({
    # Encryption at rest configuration
    EncryptionConfiguration = {
      # Enable at-rest encryption for S3
      AtRestEncryptionConfiguration = {
        S3EncryptionConfiguration = {
          EncryptionMode = "SSE-KMS"
          AwsKmsKey      = aws_kms_key.emr_encryption.arn
        }
        # Enable at-rest encryption for local disks
        LocalDiskEncryptionConfiguration = {
          EncryptionKeyProviderType = "AwsKms"
          AwsKmsKey                 = aws_kms_key.emr_encryption.arn
        }
      }

      # Enable in-transit encryption
      EnableInTransitEncryption = true
      InTransitEncryptionConfiguration = {
        # TLS certificate configuration for in-transit encryption
        TLSCertificateConfiguration = {
          CertificateProviderType = "PEM"
          S3Object                = "s3://${aws_s3_bucket.certificates.id}/${var.certificate_s3_prefix}/certificateBundle.zip"
        }
      }
    }

    # Instance metadata service configuration (IMDSv2)
    InstanceMetadataServiceConfiguration = {
      MinimumInstanceMetadataServiceVersion = 2
      HttpPutResponseHopLimit               = 1
    }
  })

  depends_on = [
    aws_kms_key.emr_encryption,
    aws_s3_bucket.certificates
  ]
}
