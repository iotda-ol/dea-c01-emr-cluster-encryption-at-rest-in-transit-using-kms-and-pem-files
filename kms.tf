# KMS key for EMR encryption at rest
resource "aws_kms_key" "emr_encryption" {
  description             = "KMS key for EMR cluster encryption at rest"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  # Key policy following least privilege principle
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow EMR to use the key"
        Effect = "Allow"
        Principal = {
          Service = "elasticmapreduce.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey",
          "kms:CreateGrant"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "kms:ViaService" = [
              "s3.${var.aws_region}.amazonaws.com",
              "ec2.${var.aws_region}.amazonaws.com"
            ]
          }
        }
      },
      {
        Sid    = "Allow EC2 instances to use the key"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.emr_ec2_role.arn
        }
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ]
        Resource = "*"
      },
      {
        Sid    = "Allow S3 to use the key for server-side encryption"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-emr-kms-key"
  }
}

# KMS key alias for easier identification
resource "aws_kms_alias" "emr_encryption" {
  name          = "alias/${var.project_name}-${var.environment}-emr-encryption"
  target_key_id = aws_kms_key.emr_encryption.key_id
}
