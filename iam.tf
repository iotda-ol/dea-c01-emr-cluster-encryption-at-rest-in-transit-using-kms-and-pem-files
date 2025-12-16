# IAM Role for EMR Service
resource "aws_iam_role" "emr_service_role" {
  name = "${var.project_name}-${var.environment}-emr-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "elasticmapreduce.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-emr-service-role"
  }
}

# Attach AWS managed policy for EMR service role
resource "aws_iam_role_policy_attachment" "emr_service_policy" {
  role       = aws_iam_role.emr_service_role.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AmazonElasticMapReduceRole"
}

# Custom policy for EMR service role to access KMS
resource "aws_iam_role_policy" "emr_service_kms_policy" {
  name = "${var.project_name}-${var.environment}-emr-service-kms-policy"
  role = aws_iam_role.emr_service_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey",
          "kms:CreateGrant"
        ]
        Resource = aws_kms_key.emr_encryption.arn
      }
    ]
  })
}

# IAM Role for EMR EC2 instances
resource "aws_iam_role" "emr_ec2_role" {
  name = "${var.project_name}-${var.environment}-emr-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-emr-ec2-role"
  }
}

# Attach AWS managed policy for EMR EC2 role
resource "aws_iam_role_policy_attachment" "emr_ec2_policy" {
  role       = aws_iam_role.emr_ec2_role.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AmazonElasticMapReduceforEC2Role"
}

# Custom policy for EMR EC2 instances - S3 access with least privilege
resource "aws_iam_role_policy" "emr_ec2_s3_policy" {
  name = "${var.project_name}-${var.environment}-emr-ec2-s3-policy"
  role = aws_iam_role.emr_ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCertificatesBucketRead"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.certificates.arn,
          "${aws_s3_bucket.certificates.arn}/*"
        ]
      },
      {
        Sid    = "AllowLogsBucketReadWrite"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.logs.arn,
          "${aws_s3_bucket.logs.arn}/*"
        ]
      }
    ]
  })
}

# Custom policy for EMR EC2 instances - KMS access
resource "aws_iam_role_policy" "emr_ec2_kms_policy" {
  name = "${var.project_name}-${var.environment}-emr-ec2-kms-policy"
  role = aws_iam_role.emr_ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ]
        Resource = aws_kms_key.emr_encryption.arn
      }
    ]
  })
}

# Instance profile for EMR EC2 instances
resource "aws_iam_instance_profile" "emr_ec2_instance_profile" {
  name = "${var.project_name}-${var.environment}-emr-ec2-instance-profile"
  role = aws_iam_role.emr_ec2_role.name

  tags = {
    Name = "${var.project_name}-${var.environment}-emr-ec2-instance-profile"
  }
}

# IAM Role for EMR Auto Scaling
resource "aws_iam_role" "emr_autoscaling_role" {
  name = "${var.project_name}-${var.environment}-emr-autoscaling-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = [
            "elasticmapreduce.amazonaws.com",
            "application-autoscaling.amazonaws.com"
          ]
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-emr-autoscaling-role"
  }
}

# Attach AWS managed policy for EMR autoscaling
resource "aws_iam_role_policy_attachment" "emr_autoscaling_policy" {
  role       = aws_iam_role.emr_autoscaling_role.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AmazonElasticMapReduceforAutoScalingRole"
}
