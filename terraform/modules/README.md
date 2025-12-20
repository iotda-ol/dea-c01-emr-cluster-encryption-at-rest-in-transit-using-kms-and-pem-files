# Terraform Modules

This directory contains reusable Terraform modules for deploying EMR clusters with encryption.

## Available Modules

### 1. KMS Module (`kms/`)
Creates and manages AWS KMS keys for encryption.

**Features**:
- Customer-managed CMK
- Automatic key rotation
- Granular key policies
- Key aliases

**Usage**:
```hcl
module "kms" {
  source = "../../modules/kms"
  
  project_name = "emr-encryption"
  environment  = "dev"
  
  key_administrators = ["arn:aws:iam::123456789012:root"]
  key_users = ["arn:aws:iam::123456789012:role/EMR_EC2_DefaultRole"]
}
```

### 2. VPC Module (`vpc/`)
Creates isolated network infrastructure for EMR clusters.

**Features**:
- VPC with public and private subnets
- Internet Gateway and NAT Gateway
- Route tables
- Security groups for EMR

**Usage**:
```hcl
module "vpc" {
  source = "../../modules/vpc"
  
  project_name        = "emr-encryption"
  environment         = "dev"
  vpc_cidr            = "10.0.0.0/16"
  public_subnet_cidr  = "10.0.1.0/24"
  private_subnet_cidr = "10.0.2.0/24"
  availability_zone   = "us-east-1a"
}
```

### 3. S3 Module (`s3/`)
Creates encrypted S3 buckets for EMR data and logs.

**Features**:
- Three buckets: logs, data, scripts
- KMS encryption
- Versioning
- Lifecycle policies
- Public access blocked

**Usage**:
```hcl
module "s3" {
  source = "../../modules/s3"
  
  project_name            = "emr-encryption"
  environment             = "dev"
  kms_key_id             = module.kms.key_id
  enable_versioning      = true
  enable_lifecycle_rules = true
}
```

### 4. Security Config Module (`security-config/`)
Creates EMR security configuration for encryption.

**Features**:
- Encryption at rest configuration
- Encryption in transit configuration
- PEM certificate integration

**Usage**:
```hcl
module "security_config" {
  source = "../../modules/security-config"
  
  project_name                 = "emr-encryption"
  environment                  = "dev"
  enable_at_rest_encryption    = true
  enable_in_transit_encryption = true
  kms_key_id                   = module.kms.key_id
  certificates_s3_bucket       = module.s3.scripts_bucket_name
}
```

### 5. EMR Module (`emr/`)
Deploys EMR cluster with encryption enabled.

**Features**:
- Configurable instance types and counts
- Security configuration integration
- Auto-scaling support
- Bootstrap actions
- Step execution

**Usage**:
```hcl
module "emr" {
  source = "../../modules/emr"
  
  project_name              = "emr-encryption"
  environment               = "dev"
  subnet_id                 = module.vpc.private_subnet_id
  release_label             = "emr-6.15.0"
  applications              = ["Hadoop", "Spark", "Hive"]
  master_instance_type      = "m5.xlarge"
  core_instance_type        = "m5.xlarge"
  core_instance_count       = 2
  security_configuration    = module.security_config.security_configuration_name
  key_name                  = "emr-cluster-key"
  service_role              = aws_iam_role.emr_service_role.arn
  instance_profile          = aws_iam_instance_profile.emr_ec2_instance_profile.arn
}
```

## Module Design Principles

1. **Modularity**: Each module focuses on a single responsibility
2. **Reusability**: Can be used across different environments
3. **Configurability**: Sensible defaults with override capability
4. **Security**: Secure by default configuration
5. **Documentation**: Comprehensive README and examples

## Module Dependencies

```
kms (independent)
  ↓
vpc (independent)
  ↓
s3 (depends on kms)
  ↓
security-config (depends on kms, s3)
  ↓
emr (depends on vpc, security-config, s3)
```

## Best Practices

1. **Version Pinning**: Pin module versions in production
2. **State Management**: Use remote state for team collaboration
3. **Testing**: Test modules in isolation before integration
4. **Tagging**: Consistent tagging across all resources
5. **Documentation**: Keep module READMEs up to date

## Examples

See `terraform/environments/` for complete usage examples:
- `dev/` - Development environment
- `staging/` - Staging environment
- `prod/` - Production environment
