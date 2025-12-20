# KMS Module

This module creates and manages KMS keys for EMR cluster encryption.

## Features

- Creates customer-managed KMS key
- Configures key policy with granular permissions
- Enables automatic key rotation
- Creates key alias for easy reference
- Supports multiple key administrators and users

## Usage

```hcl
module "kms" {
  source = "../../modules/kms"

  project_name = "emr-encryption"
  environment  = "dev"
  
  key_description = "KMS key for EMR cluster encryption"
  
  key_administrators = [
    "arn:aws:iam::123456789012:root"
  ]
  
  key_users = [
    "arn:aws:iam::123456789012:role/EMR_DefaultRole",
    "arn:aws:iam::123456789012:role/EMR_EC2_DefaultRole"
  ]

  tags = {
    Project     = "emr-encryption"
    Environment = "dev"
  }
}
```

## Outputs

- `key_id` - KMS key ID
- `key_arn` - KMS key ARN
- `alias_name` - KMS key alias name
- `alias_arn` - KMS key alias ARN
