# KMS Module for EMR Encryption

resource "aws_kms_key" "main" {
  description             = var.key_description
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = var.enable_key_rotation

  policy = data.aws_iam_policy_document.kms_key_policy.json

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-kms-key"
    }
  )
}

resource "aws_kms_alias" "main" {
  name          = "alias/${var.project_name}-${var.environment}-emr-encryption"
  target_key_id = aws_kms_key.main.key_id
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "kms_key_policy" {
  # Allow root account full access
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  # Allow key administrators
  statement {
    sid    = "Allow Key Administrators"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = var.key_administrators
    }
    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:TagResource",
      "kms:UntagResource",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion"
    ]
    resources = ["*"]
  }

  # Allow key users
  statement {
    sid    = "Allow Key Users"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = var.key_users
    }
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:CreateGrant"
    ]
    resources = ["*"]
  }

  # Allow CloudWatch Logs
  statement {
    sid    = "Allow CloudWatch Logs"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["logs.${var.aws_region}.amazonaws.com"]
    }
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*"
    ]
    resources = ["*"]
  }

  # Allow S3
  statement {
    sid    = "Allow S3"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    resources = ["*"]
  }
}
