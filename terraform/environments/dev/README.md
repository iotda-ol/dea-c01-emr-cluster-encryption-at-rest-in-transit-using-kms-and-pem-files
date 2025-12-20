# Development Environment

This directory contains Terraform configuration for the development environment.

## Quick Start

```bash
# Copy example variables
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your values
# Important: Set your key_pair_name

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply changes
terraform apply
```

## Prerequisites

1. AWS CLI configured with appropriate credentials
2. EC2 key pair created (referenced in terraform.tfvars)
3. S3 bucket for Terraform state (optional but recommended)

## Configuration Files

- `main.tf` - Main configuration with module calls
- `variables.tf` - Variable definitions
- `outputs.tf` - Output values
- `terraform.tfvars.example` - Example variable values
- `terraform.tfvars` - Your actual values (not committed)

## Resources Created

This configuration creates:
- VPC with public and private subnets
- KMS key for encryption
- 3 S3 buckets (logs, data, scripts)
- NAT Gateway and Internet Gateway
- Security groups
- (Additional resources as you progress through the guide)

## Cost Estimate

Running this development environment 24/7:
- **With auto-termination**: ~$50-100/month (mostly S3 and NAT Gateway)
- **Without auto-termination**: ~$250-500/month (includes EMR cluster)

**Recommendation**: Keep `auto_terminate = true` in development.

## Important Notes

1. **Never commit terraform.tfvars** - Contains sensitive values
2. **Review costs** - Understand what you're deploying
3. **Enable auto-termination** - Save money in dev
4. **Tag resources** - For cost tracking

## State Management

For team collaboration, configure remote state:

1. Create S3 bucket:
```bash
aws s3 mb s3://emr-encryption-tfstate-$(aws sts get-caller-identity --query Account --output text)
```

2. Create DynamoDB table:
```bash
aws dynamodb create-table \
  --table-name emr-encryption-tfstate-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

3. Uncomment backend configuration in `main.tf`

4. Run `terraform init` to migrate state

## Next Steps

After applying this configuration:

1. Verify resources in AWS Console
2. Run validation script:
```bash
python3 ../../../scripts/validation/validate-infrastructure.py --environment dev
```

3. Continue with the instruction manual:
   - [Intermediate Level](../../../docs/instructions/intermediate/steps-26-50.md)
   - [Advanced Level](../../../docs/instructions/advanced/steps-51-75.md)

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

⚠️ **Warning**: This will delete all data in S3 buckets. Backup important data first!
