# EMR Cluster Encryption - Complete Implementation Guide

This repository provides a **comprehensive, production-ready implementation** of Amazon EMR clusters with full encryption at rest and in transit. It includes a complete 100-step learning path from novice to expert, modular reusable code, and follows DEA-C01 AWS Certified Data Analytics certification best practices.

## 🎯 Overview

This project demonstrates how to launch and manage Amazon EMR clusters with:
- ✅ **Encryption at Rest**: AWS KMS-encrypted EBS volumes and S3 buckets
- ✅ **Encryption in Transit**: TLS/SSL with PEM certificates for all network communication
- ✅ **Infrastructure as Code**: Fully modular Terraform implementation
- ✅ **Automation**: Python utilities for deployment, monitoring, and management
- ✅ **Production Ready**: Security hardening, monitoring, CI/CD, and disaster recovery

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/iotda-ol/dea-c01-emr-cluster-encryption-at-rest-in-transit-using-kms-and-pem-files.git
cd dea-c01-emr-cluster-encryption-at-rest-in-transit-using-kms-and-pem-files

# Run setup
bash scripts/setup/setup.sh

# Deploy infrastructure
cd terraform/environments/dev
terraform init
terraform plan
terraform apply
```

See [Quick Start Guide](docs/QUICKSTART.md) for detailed instructions.

## 📚 100-Step Learning Path

This repository includes a comprehensive **100-step instruction manual** that takes you from novice to expert:

### [📖 Complete Guide](docs/instructions/README.md)

- **[Beginner (Steps 1-25)](docs/instructions/beginner/steps-01-25.md)** - AWS basics, environment setup, prerequisites
- **[Intermediate (Steps 26-50)](docs/instructions/intermediate/steps-26-50.md)** - Terraform modules, infrastructure deployment
- **[Advanced (Steps 51-75)](docs/instructions/advanced/steps-51-75.md)** - Encryption implementation, automation, monitoring
- **[Expert (Steps 76-100)](docs/instructions/expert/steps-76-100.md)** - Production optimization, advanced topics, mastery

**Total Learning Time**: 24-32 hours for complete mastery

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         AWS Cloud                            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                VPC (Isolated Network)                │   │
│  │                                                       │   │
│  │  Public Subnet          Private Subnet               │   │
│  │  ┌──────────┐          ┌──────────────────┐         │   │
│  │  │   NAT    │─────────▶│   EMR Cluster    │         │   │
│  │  │ Gateway  │          │  - Master Node   │         │   │
│  │  └──────────┘          │  - Core Nodes    │         │   │
│  │                        │  - Task Nodes    │         │   │
│  │                        └──────────────────┘         │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │           S3 Buckets (KMS Encrypted)                 │  │
│  │  • Logs  • Data  • Scripts/Certificates             │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │           KMS (Key Management Service)               │  │
│  │  • Customer Master Key • Auto Rotation               │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

See [Architecture Documentation](docs/architecture/overview.md) for details.

## 📁 Project Structure

```
.
├── docs/                           # Comprehensive documentation
│   ├── instructions/              # 100-step learning guide
│   │   ├── beginner/             # Steps 1-25
│   │   ├── intermediate/         # Steps 26-50
│   │   ├── advanced/             # Steps 51-75
│   │   └── expert/               # Steps 76-100
│   ├── architecture/              # Architecture diagrams and docs
│   ├── troubleshooting/           # Common issues and solutions
│   └── examples/                  # Example configurations
│
├── terraform/                      # Infrastructure as Code
│   ├── modules/                   # Reusable Terraform modules
│   │   ├── kms/                  # KMS encryption module
│   │   ├── vpc/                  # Network infrastructure
│   │   ├── s3/                   # S3 buckets with encryption
│   │   ├── emr/                  # EMR cluster module
│   │   └── security-config/      # EMR security configuration
│   └── environments/              # Environment-specific configs
│       ├── dev/                  # Development environment
│       ├── staging/              # Staging environment
│       └── prod/                 # Production environment
│
├── python/                         # Python utilities and automation
│   ├── src/                       # Source code
│   │   ├── certificate_manager/  # Certificate management
│   │   ├── deployment/           # Deployment automation
│   │   ├── encryption/           # Encryption verification
│   │   ├── monitoring/           # Monitoring and alerting
│   │   └── utils/                # Utility functions
│   └── tests/                     # Unit and integration tests
│       ├── unit/
│       └── integration/
│
├── scripts/                        # Shell scripts and automation
│   ├── setup/                    # Setup and bootstrap scripts
│   ├── deployment/               # Deployment scripts
│   ├── validation/               # Validation and testing
│   └── cleanup/                  # Cleanup scripts
│
└── config/                         # Configuration files
    └── templates/                 # Configuration templates
```

## ✨ Key Features

### 🔒 Security
- **Encryption at Rest**: KMS encryption for EBS, S3, and local disks
- **Encryption in Transit**: TLS/SSL for all communications
- **IAM Best Practices**: Least privilege access, role-based permissions
- **Network Isolation**: Private subnets, security groups
- **Compliance**: DEA-C01 certification-ready implementation

### 🔧 Modularity & Reusability
- **Terraform Modules**: Fully modular and reusable infrastructure code
- **Python Packages**: Well-organized, reusable Python utilities
- **Multi-Environment**: Support for dev, staging, and production
- **DRY Principle**: Maximum code reuse, minimal duplication

### 🤖 Automation
- **Deployment**: Automated cluster deployment and configuration
- **Monitoring**: CloudWatch integration, custom metrics
- **Certificate Management**: Automated certificate generation and rotation
- **Validation**: Automated verification of encryption settings
- **CI/CD Ready**: GitHub Actions workflows included

### 📊 Monitoring & Operations
- **CloudWatch Dashboards**: Pre-configured dashboards
- **Alerting**: Automated alerts for critical metrics
- **Logging**: Centralized logging with CloudWatch Logs
- **Cost Monitoring**: Track and optimize AWS costs
- **Performance Metrics**: Custom performance monitoring

## 🎓 Learning Objectives

By following this guide, you will:

1. ✅ Master AWS EMR deployment and configuration
2. ✅ Implement comprehensive encryption (at-rest and in-transit)
3. ✅ Use Terraform for infrastructure as code
4. ✅ Automate deployment with Python
5. ✅ Set up monitoring and alerting
6. ✅ Implement security best practices
7. ✅ Prepare for DEA-C01 certification
8. ✅ Build production-ready data infrastructure

## 📋 Prerequisites

- AWS Account with appropriate permissions
- AWS CLI installed and configured
- Python 3.8 or higher
- Terraform 1.0 or higher
- Git
- Basic command-line knowledge

See [Prerequisites Validation](scripts/setup/validate-prerequisites.py) to check your setup.

## 🛠️ Technologies Used

- **AWS Services**: EMR, KMS, S3, VPC, EC2, IAM, CloudWatch
- **IaC**: Terraform
- **Programming**: Python, Bash
- **Big Data**: Apache Hadoop, Spark, Hive
- **Security**: KMS, TLS/SSL, PEM certificates

## 📖 Documentation

- **[Quick Start](docs/QUICKSTART.md)** - Get started in 5 minutes
- **[100-Step Guide](docs/instructions/README.md)** - Complete learning path
- **[Architecture](docs/architecture/overview.md)** - System architecture
- **[Troubleshooting](docs/troubleshooting/common-issues.md)** - Common issues and solutions
- **[Examples](docs/examples/)** - Reference implementations

## 🤝 Contributing

Contributions are welcome! This project is designed to be:
- Educational and comprehensive
- Production-ready and secure
- Well-documented and maintainable

## 📜 License

This project is provided as-is for educational purposes.

## 🏆 DEA-C01 Certification

This project demonstrates key competencies for the AWS Certified Data Analytics - Specialty (DEA-C01) certification:

- ✅ Design and implement data security
- ✅ Deploy and manage EMR clusters
- ✅ Implement encryption at rest and in transit
- ✅ Use Infrastructure as Code
- ✅ Implement monitoring and logging
- ✅ Optimize costs and performance

## 🌟 Acknowledgments

Built following AWS Well-Architected Framework and DEA-C01 best practices.

---

**Ready to become an EMR encryption expert?** Start with the [Beginner Guide](docs/instructions/beginner/steps-01-25.md)!
# Secure Amazon EMR Cluster with Encryption at Rest and In Transit

This repository demonstrates how to launch a production-ready Amazon EMR cluster with comprehensive data encryption following AWS DEA-C01 (Data Engineer Associate) best practices. The solution implements:

- **Encryption at Rest**: AWS KMS-based encryption for S3 data and EBS volumes
- **Encryption in Transit**: PEM certificate-based TLS/SSL encryption for inter-node communication
- **IAM Least Privilege**: Granular role-based access control
- **Comprehensive Logging**: CloudWatch and S3-based audit trails
- **Infrastructure as Code**: Terraform for reproducible deployments

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         VPC (User Provided)                      │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                    EMR Cluster                              │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │ │
│  │  │ Master Node  │  │  Core Node   │  │  Core Node   │    │ │
│  │  │   (m5.xlarge)│  │  (m5.xlarge) │  │  (m5.xlarge) │    │ │
│  │  │              │  │              │  │              │    │ │
│  │  │ • Spark      │  │ • HDFS       │  │ • HDFS       │    │ │
│  │  │ • Hadoop     │  │ • Task Exec  │  │ • Task Exec  │    │ │
│  │  │ • Hive       │  │              │  │              │    │ │
│  │  └──────────────┘  └──────────────┘  └──────────────┘    │ │
│  │         │                  │                  │            │ │
│  │         └──────────────────┴──────────────────┘            │ │
│  │              TLS Encrypted (PEM Certificates)              │ │
│  └────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                            │
                            │ KMS Encrypted
                            │
         ┌──────────────────┴──────────────────┐
         │                                      │
    ┌────▼────┐                        ┌───────▼──────┐
    │   S3    │                        │     KMS      │
    │ Buckets │                        │  Master Key  │
    │         │                        │              │
    │ • Logs  │                        │ • Auto       │
    │ • Certs │                        │   Rotation   │
    └─────────┘                        │ • Audit      │
                                       └──────────────┘
```

## Features

### 🔐 Security

- **Encryption at Rest**
  - S3 server-side encryption with AWS KMS
  - EBS volume encryption for all cluster nodes
  - Customer-managed KMS key with automatic rotation
  
- **Encryption in Transit**
  - TLS/SSL encryption for inter-node communication
  - Self-signed PEM certificates stored securely in S3
  - Encrypted Spark shuffle data
  - HTTPS for all web interfaces

- **IAM Least Privilege**
  - Separate roles for EMR service, EC2 instances, and autoscaling
  - Resource-based policies for S3 and KMS
  - Condition-based access controls

- **Network Security**
  - VPC deployment with security groups
  - Minimal ingress rules
  - IMDSv2 enforcement

### 📊 Logging and Monitoring

- Centralized logging to S3
- CloudWatch integration
- Configurable log retention (90 days default)
- Encrypted log storage

### 🚀 Infrastructure as Code

- Complete Terraform configuration
- Modular and reusable design
- Configurable variables
- Output values for integration

## Prerequisites

- **Terraform**: >= 1.0
- **Python**: >= 3.8
- **AWS CLI**: Configured with appropriate credentials
- **AWS Account**: With permissions to create EMR, KMS, S3, IAM resources
- **VPC**: Existing VPC with at least one subnet

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/iotda-ol/dea-c01-emr-cluster-encryption-at-rest-in-transit-using-kms-and-pem-files.git
cd dea-c01-emr-cluster-encryption-at-rest-in-transit-using-kms-and-pem-files
```

### 2. Install Python Dependencies

```bash
pip install -r requirements.txt
```

### 3. Generate PEM Certificates

```bash
python scripts/generate_certificates.py --output-dir ./certificates
```

This creates:
- `privateKey.pem` - RSA private key
- `certificateChain.pem` - Self-signed certificate
- `certificateBundle.zip` - Bundle for EMR (contains both files)

**Security Note**: Keep `privateKey.pem` secure and never commit it to version control.

### 4. Configure Terraform Variables

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and provide your configuration:

```hcl
aws_region  = "us-east-1"
project_name = "my-emr-project"
environment  = "dev"

# Required: Your VPC and Subnet
subnet_id = "subnet-xxxxxxxxx"
vpc_id    = "vpc-xxxxxxxxx"

# Optional: CIDR blocks for access
allowed_cidr_blocks = ["10.0.0.0/8"]

# Optional: EC2 key pair for SSH
key_name = "my-keypair"
```

### 5. Initialize Terraform

```bash
terraform init
```

### 6. Plan and Apply Infrastructure

```bash
# Review the execution plan
terraform plan

# Apply the configuration
terraform apply
```

**Note**: The initial apply will create S3 buckets and other resources but the EMR cluster creation will fail if certificates are not uploaded.

### 7. Upload Certificates to S3

After Terraform creates the S3 bucket, upload the certificate bundle:

```bash
# Get the bucket name from Terraform output
BUCKET_NAME=$(terraform output -raw certificates_bucket_name)

# Upload the certificate bundle
python scripts/upload_certificates.py \
  --bucket-name "$BUCKET_NAME" \
  --bundle-path ./certificates/certificateBundle.zip
```

### 8. Verify EMR Cluster

```bash
# Get cluster details
terraform output

# Check cluster status in AWS Console or CLI
aws emr describe-cluster --cluster-id $(terraform output -raw emr_cluster_id)
```

## Project Structure

```
.
├── README.md                      # This file
├── SECURITY.md                    # Security best practices documentation
├── .gitignore                     # Git ignore rules
├── requirements.txt               # Python dependencies
├── terraform.tfvars.example       # Terraform variables template
├── variables.tf                   # Terraform input variables
├── main.tf                        # Terraform provider configuration
├── outputs.tf                     # Terraform outputs
├── kms.tf                         # KMS key configuration
├── s3.tf                          # S3 buckets for logs and certificates
├── iam.tf                         # IAM roles and policies
├── security_groups.tf             # Network security groups
├── emr_security_config.tf         # EMR security configuration
├── emr_cluster.tf                 # EMR cluster definition
└── scripts/
    ├── generate_certificates.py   # Certificate generation script
    └── upload_certificates.py     # Certificate upload script
```

## Configuration

### Terraform Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `aws_region` | AWS region | `us-east-1` | No |
| `project_name` | Project name for resources | `dea-c01-emr-secure` | No |
| `environment` | Environment (dev/staging/prod) | `dev` | No |
| `subnet_id` | Subnet for EMR deployment | - | Yes |
| `vpc_id` | VPC for EMR deployment | - | Yes |
| `emr_release_label` | EMR version | `emr-6.15.0` | No |
| `emr_master_instance_type` | Master node instance type | `m5.xlarge` | No |
| `emr_core_instance_type` | Core node instance type | `m5.xlarge` | No |
| `emr_core_instance_count` | Number of core nodes | `2` | No |
| `allowed_cidr_blocks` | CIDR blocks for access | `[]` | No |
| `key_name` | EC2 key pair name | `""` | No |
| `enable_termination_protection` | Enable termination protection | `false` | No |
| `log_retention_days` | Log retention period | `90` | No |

### Python Scripts

#### generate_certificates.py

```bash
python scripts/generate_certificates.py \
  --output-dir ./certificates \
  --common-name "*.compute.internal" \
  --organization "My Company" \
  --validity-days 365 \
  --key-size 2048
```

Options:
- `--output-dir`: Directory for certificate files (default: `./certificates`)
- `--common-name`: Certificate common name (default: `*.compute.internal`)
- `--organization`: Organization name (default: `EMR Cluster`)
- `--validity-days`: Certificate validity period (default: 365)
- `--key-size`: RSA key size, 2048 or 4096 (default: 2048)

#### upload_certificates.py

```bash
python scripts/upload_certificates.py \
  --bucket-name my-bucket-name \
  --bundle-path ./certificates/certificateBundle.zip \
  --s3-prefix certificates \
  --aws-region us-east-1
```

Options:
- `--bucket-name`: S3 bucket name (required)
- `--bundle-path`: Path to certificate bundle (default: `./certificates/certificateBundle.zip`)
- `--s3-prefix`: S3 prefix/folder (default: `certificates`)
- `--aws-region`: AWS region (optional)

## Security Best Practices

This implementation follows AWS DEA-C01 best practices:

✅ **Encryption at Rest**
- KMS-based encryption for all data
- Automatic key rotation enabled
- Least-privilege key policies

✅ **Encryption in Transit**
- TLS/SSL for all communications
- Strong cipher suites
- Certificate lifecycle management

✅ **IAM Least Privilege**
- Separate roles for different functions
- Resource-based policies
- Condition-based access

✅ **Logging and Monitoring**
- Comprehensive CloudWatch logging
- S3 audit logs
- Log encryption and retention

✅ **Network Security**
- VPC isolation
- Security group restrictions
- IMDSv2 enforcement

For detailed security documentation, see [SECURITY.md](SECURITY.md).

## Maintenance

### Certificate Rotation

Certificates should be rotated before expiration:

1. Generate new certificates:
   ```bash
   python scripts/generate_certificates.py --output-dir ./certificates-new
   ```

2. Upload to S3:
   ```bash
   python scripts/upload_certificates.py \
     --bucket-name $(terraform output -raw certificates_bucket_name) \
     --bundle-path ./certificates-new/certificateBundle.zip
   ```

3. Restart EMR cluster or apply configuration update

### KMS Key Rotation

KMS key rotation is enabled automatically (annual rotation). To manually rotate:

1. Update KMS key in AWS Console or via API
2. No changes required in Terraform
3. Existing encrypted data remains accessible

### Cluster Scaling

To scale the cluster:

1. Update `emr_core_instance_count` in `terraform.tfvars`
2. Run `terraform apply`
3. EMR will add or remove core nodes

### Monitoring

Key metrics to monitor:

- EMR cluster health and status
- KMS key usage and errors
- S3 access patterns
- CloudWatch logs for errors
- Certificate expiration dates

## Troubleshooting

### Certificate Upload Issues

**Problem**: Certificate upload fails

**Solution**:
```bash
# Verify AWS credentials
aws sts get-caller-identity

# Check bucket exists
aws s3 ls s3://$(terraform output -raw certificates_bucket_name)

# Verify bucket encryption
aws s3api get-bucket-encryption \
  --bucket $(terraform output -raw certificates_bucket_name)
```

### EMR Cluster Creation Fails

**Problem**: EMR cluster fails to start

**Solution**:
1. Check EMR cluster logs in S3
2. Verify security group rules allow required ports
3. Ensure certificates are uploaded to correct S3 location
4. Verify IAM roles have correct permissions

### KMS Permission Denied

**Problem**: KMS encryption/decryption fails

**Solution**:
1. Review KMS key policy
2. Verify IAM roles have KMS permissions
3. Check ViaService conditions in key policy
4. Ensure KMS key is in the same region

## Cost Optimization

Estimated costs for default configuration (us-east-1):

- **EMR Cluster**: ~$1.50/hour (3 x m5.xlarge)
- **S3 Storage**: ~$0.023/GB/month
- **KMS**: $1/month + $0.03/10k requests
- **Data Transfer**: Variable based on usage

To reduce costs:
- Use Spot instances for task nodes
- Enable EMR autoscaling
- Set appropriate log retention periods
- Use S3 Intelligent-Tiering for logs
- Terminate cluster when not in use

## License

This project is provided as-is for educational purposes.

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## Support

For issues or questions:

1. Check [SECURITY.md](SECURITY.md) for security-related topics
2. Review [Troubleshooting](#troubleshooting) section
3. Open a GitHub issue
4. Contact AWS Support for AWS-specific issues

## References

- [AWS EMR Documentation](https://docs.aws.amazon.com/emr/)
- [AWS KMS Developer Guide](https://docs.aws.amazon.com/kms/)
- [DEA-C01 Certification Guide](https://aws.amazon.com/certification/certified-data-engineer-associate/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/)

## Acknowledgments

This implementation follows AWS Well-Architected Framework principles and DEA-C01 exam requirements for data engineering workloads.
