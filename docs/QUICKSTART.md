# Quick Start Guide

This guide helps you get started quickly with the EMR cluster encryption project.

## Prerequisites

Before you begin, ensure you have:
- AWS Account with appropriate permissions
- AWS CLI installed and configured
- Python 3.8 or higher
- Terraform 1.0 or higher
- Git installed

## 5-Minute Quick Start

### 1. Clone and Setup

```bash
# Clone the repository
git clone https://github.com/iotda-ol/dea-c01-emr-cluster-encryption-at-rest-in-transit-using-kms-and-pem-files.git
cd dea-c01-emr-cluster-encryption-at-rest-in-transit-using-kms-and-pem-files

# Run setup script
bash scripts/setup/setup.sh

# Activate Python environment
source python/venv/bin/activate
```

### 2. Configure AWS

```bash
# Configure AWS credentials if not already done
aws configure

# Verify credentials
aws sts get-caller-identity
```

### 3. Deploy Infrastructure (Development)

```bash
# Navigate to dev environment
cd terraform/environments/dev

# Initialize Terraform
terraform init

# Review the deployment plan
terraform plan

# Deploy (this will take 15-30 minutes)
terraform apply
```

### 4. Verify Deployment

```bash
# Get cluster ID
CLUSTER_ID=$(terraform output -raw emr_cluster_id)

# Check cluster status
aws emr describe-cluster --cluster-id $CLUSTER_ID --query 'Cluster.Status.State'

# Verify encryption
python3 ../../python/src/encryption/verify_encryption.py --cluster-id $CLUSTER_ID
```

## What Gets Created

The quick start creates:
- ✅ VPC with public and private subnets
- ✅ KMS key for encryption
- ✅ 3 S3 buckets (logs, data, scripts) with encryption
- ✅ EMR cluster with encryption at rest and in transit
- ✅ Security groups and IAM roles
- ✅ CloudWatch monitoring

## Next Steps

### For Learning (Recommended)

Follow the comprehensive 100-step guide:
1. [Beginner (1-25)](docs/instructions/beginner/steps-01-25.md) - Foundations
2. [Intermediate (26-50)](docs/instructions/intermediate/steps-26-50.md) - Infrastructure
3. [Advanced (51-75)](docs/instructions/advanced/steps-51-75.md) - Security & Operations
4. [Expert (76-100)](docs/instructions/expert/steps-76-100.md) - Production & Optimization

### For Production Use

1. Review [Architecture Documentation](docs/architecture/overview.md)
2. Customize configurations in `terraform/environments/prod/`
3. Follow security hardening guidelines
4. Set up monitoring and alerting
5. Implement backup and disaster recovery

## Cleanup

To avoid charges, destroy the infrastructure when done:

```bash
cd terraform/environments/dev
terraform destroy
```

## Cost Estimate

Development environment typical costs (USD/month):
- EMR cluster (if running 24/7): $200-400
- S3 storage: $5-20
- KMS: $1
- Data transfer: $10-50

**Tip**: Enable auto-termination for dev clusters to reduce costs.

## Getting Help

- [Troubleshooting Guide](docs/troubleshooting/common-issues.md)
- [Architecture Docs](docs/architecture/)
- [FAQ](docs/FAQ.md)
- GitHub Issues

## Learning Path

```
Quick Start (You are here!)
    ↓
Beginner Level (Steps 1-25) - Learn AWS & EMR basics
    ↓
Intermediate Level (Steps 26-50) - Master Terraform & Infrastructure
    ↓
Advanced Level (Steps 51-75) - Implement security & automation
    ↓
Expert Level (Steps 76-100) - Production optimization
```

## Important Security Notes

⚠️ **Never commit**:
- AWS credentials
- PEM certificates
- `.tfvars` files with sensitive data
- Private keys

✅ **Always**:
- Use separate AWS accounts for dev/prod
- Enable MFA on AWS accounts
- Rotate credentials regularly
- Follow principle of least privilege

Happy learning! 🚀
