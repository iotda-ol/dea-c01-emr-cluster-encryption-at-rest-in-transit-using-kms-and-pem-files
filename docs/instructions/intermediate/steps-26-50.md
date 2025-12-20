# Intermediate Level: Steps 26-50

## Terraform Infrastructure Deployment (Comfortable Beginner to Intermediate)

---

### Step 26: Initialize Terraform Backend

**Objective**: Set up remote state storage in S3.

**Actions**:
```bash
cd terraform/environments/dev

# Create S3 bucket for Terraform state
aws s3 mb s3://emr-encryption-tfstate-$(aws sts get-caller-identity --query Account --output text)

# Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name emr-encryption-tfstate-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

**Verification**:
```bash
aws s3 ls | grep tfstate
aws dynamodb list-tables | grep lock
```

**Expected Output**: Bucket and table exist

---

### Step 27: Configure Terraform Backend

**Objective**: Configure Terraform to use S3 backend.

**Actions**:
Create `terraform/environments/dev/backend.tf`:
```hcl
terraform {
  backend "s3" {
    bucket         = "emr-encryption-tfstate-ACCOUNT_ID"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "emr-encryption-tfstate-lock"
    encrypt        = true
  }
}
```

Replace `ACCOUNT_ID` with your AWS account ID.

**Verification**:
```bash
terraform init
```

**Expected Output**: `Terraform has been successfully initialized!`

---

### Step 28: Create Terraform Variables File

**Objective**: Define environment-specific variables.

**Actions**:
Create `terraform/environments/dev/terraform.tfvars`:
```hcl
# Project configuration
project_name = "emr-encryption"
environment  = "dev"
aws_region   = "us-east-1"

# Network configuration
vpc_cidr            = "10.0.0.0/16"
public_subnet_cidr  = "10.0.1.0/24"
private_subnet_cidr = "10.0.2.0/24"

# EMR configuration
emr_release_label = "emr-6.15.0"
master_instance_type = "m5.xlarge"
core_instance_type   = "m5.xlarge"
core_instance_count  = 2

# Security
enable_encryption_at_rest    = true
enable_encryption_in_transit = true
key_pair_name               = "emr-cluster-key"

# Tags
tags = {
  Project     = "emr-encryption"
  Environment = "dev"
  ManagedBy   = "terraform"
  Purpose     = "DEA-C01-demo"
}
```

**Verification**: File created successfully

---

### Step 29: Understand the KMS Module

**Objective**: Learn the KMS module structure.

**Module Purpose**: Creates and manages KMS keys for encryption.

**Actions**:
Review `terraform/modules/kms/main.tf` structure:
- Creates customer-managed KMS key
- Configures key policy
- Creates aliases for easy reference
- Outputs key ID and ARN

**No verification needed** - understanding module architecture

---

### Step 30: Create KMS Module Configuration

**Objective**: Configure the KMS module for your environment.

**Actions**:
In `terraform/environments/dev/main.tf`, add:
```hcl
module "kms" {
  source = "../../modules/kms"

  project_name = var.project_name
  environment  = var.environment
  
  key_description = "KMS key for EMR cluster encryption"
  
  key_administrators = [
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
  ]
  
  key_users = [
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/EMR_DefaultRole",
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/EMR_EC2_DefaultRole"
  ]

  tags = var.tags
}
```

**Verification**: Configuration syntax is correct

---

### Step 31: Plan KMS Infrastructure

**Objective**: Preview KMS resources to be created.

**Actions**:
```bash
cd terraform/environments/dev
terraform plan -target=module.kms
```

**Verification**:
Review the plan output:
- 1 KMS key to be created
- 1 KMS alias to be created
- Key policy configuration

**Expected Output**: `Plan: 2 to add, 0 to change, 0 to destroy`

---

### Step 32: Apply KMS Infrastructure

**Objective**: Create the KMS key.

**Actions**:
```bash
terraform apply -target=module.kms
```

Type `yes` when prompted.

**Verification**:
```bash
aws kms list-keys
aws kms list-aliases | grep emr-encryption
```

**Expected Output**: Your KMS key appears in the list with an alias

---

### Step 33: Understand the VPC Module

**Objective**: Learn the VPC module structure.

**Module Purpose**: Creates isolated network infrastructure.

**Components**:
- VPC with custom CIDR
- Public subnet (for NAT gateway/bastion)
- Private subnet (for EMR cluster)
- Internet Gateway
- NAT Gateway
- Route tables
- Security groups

**Actions**:
Review `terraform/modules/vpc/main.tf`

**No verification needed** - understanding module architecture

---

### Step 34: Create VPC Module Configuration

**Objective**: Configure the VPC module.

**Actions**:
Add to `terraform/environments/dev/main.tf`:
```hcl
module "vpc" {
  source = "../../modules/vpc"

  project_name = var.project_name
  environment  = var.environment
  
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  
  availability_zone = "${var.aws_region}a"
  
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = var.tags
}
```

**Verification**: Configuration syntax is correct

---

### Step 35: Plan and Apply VPC Infrastructure

**Objective**: Create the network infrastructure.

**Actions**:
```bash
terraform plan -target=module.vpc
terraform apply -target=module.vpc
```

**Verification**:
```bash
# Check VPC
aws ec2 describe-vpcs --filters "Name=tag:Project,Values=emr-encryption"

# Check subnets
aws ec2 describe-subnets --filters "Name=tag:Project,Values=emr-encryption"

# Check internet gateway
aws ec2 describe-internet-gateways --filters "Name=tag:Project,Values=emr-encryption"
```

**Expected Output**: VPC, 2 subnets, internet gateway, NAT gateway created

---

### Step 36: Understand the S3 Module

**Objective**: Learn the S3 module for EMR storage.

**Module Purpose**: Creates encrypted S3 buckets for EMR data.

**Buckets Created**:
- **Logs Bucket**: EMR logs and debugging info
- **Data Bucket**: Input/output data
- **Scripts Bucket**: Bootstrap scripts and configurations

**Features**:
- Server-side encryption with KMS
- Versioning enabled
- Public access blocked
- Lifecycle policies

**Actions**:
Review `terraform/modules/s3/main.tf`

**No verification needed** - understanding module architecture

---

### Step 37: Create S3 Module Configuration

**Objective**: Configure S3 buckets with encryption.

**Actions**:
Add to `terraform/environments/dev/main.tf`:
```hcl
module "s3" {
  source = "../../modules/s3"

  project_name = var.project_name
  environment  = var.environment
  
  kms_key_id = module.kms.key_id
  
  enable_versioning = true
  enable_lifecycle_rules = true
  
  # Lifecycle configuration
  logs_expiration_days = 90
  data_expiration_days = 180
  
  tags = var.tags
}
```

**Verification**: Configuration syntax is correct

---

### Step 38: Plan and Apply S3 Infrastructure

**Objective**: Create encrypted S3 buckets.

**Actions**:
```bash
terraform plan -target=module.s3
terraform apply -target=module.s3
```

**Verification**:
```bash
# List buckets
aws s3 ls | grep emr-encryption

# Check encryption
aws s3api get-bucket-encryption --bucket emr-encryption-dev-logs-ACCOUNT_ID
```

**Expected Output**: 3 buckets created with KMS encryption enabled

---

### Step 39: Understand Security Groups

**Objective**: Learn about EMR security group requirements.

**Security Groups Needed**:
1. **Master Security Group**: Controls access to master node
2. **Core/Task Security Group**: Controls access to worker nodes
3. **Service Access Security Group**: EMR service communication

**Ports**:
- 22 (SSH): Administrative access
- 8443 (HTTPS): EMR web interfaces
- Custom ports: Hadoop, Spark, Hive services

**Actions**:
Review `terraform/modules/vpc/security-groups.tf`

**No verification needed** - understanding security architecture

---

### Step 40: Create IAM Roles for EMR

**Objective**: Set up IAM roles required by EMR.

**Actions**:
Create `terraform/environments/dev/iam.tf`:
```hcl
# EMR Service Role
resource "aws_iam_role" "emr_service_role" {
  name = "${var.project_name}-${var.environment}-emr-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "elasticmapreduce.amazonaws.com"
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "emr_service_policy" {
  role       = aws_iam_role.emr_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceRole"
}

# EC2 Instance Profile Role
resource "aws_iam_role" "emr_ec2_role" {
  name = "${var.project_name}-${var.environment}-emr-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "emr_ec2_policy" {
  role       = aws_iam_role.emr_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforEC2Role"
}

# Additional policy for KMS access
resource "aws_iam_role_policy" "emr_kms_policy" {
  name = "kms-access"
  role = aws_iam_role.emr_ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "kms:Decrypt",
        "kms:Encrypt",
        "kms:GenerateDataKey",
        "kms:DescribeKey"
      ]
      Resource = module.kms.key_arn
    }]
  })
}

resource "aws_iam_instance_profile" "emr_ec2_instance_profile" {
  name = "${var.project_name}-${var.environment}-emr-ec2-instance-profile"
  role = aws_iam_role.emr_ec2_role.name
}
```

**Verification**:
```bash
terraform plan
terraform apply
```

**Expected Output**: IAM roles and instance profile created

---

### Step 41: Verify IAM Roles

**Objective**: Confirm IAM roles are properly configured.

**Actions**:
```bash
# List roles
aws iam list-roles | grep emr-encryption

# Check role policies
aws iam list-attached-role-policies --role-name emr-encryption-dev-emr-service-role
aws iam list-attached-role-policies --role-name emr-encryption-dev-emr-ec2-role
```

**Verification**:
- Service role has AmazonElasticMapReduceRole
- EC2 role has AmazonElasticMapReduceforEC2Role
- EC2 role has KMS access policy

**Expected Output**: All required policies attached

---

### Step 42: Understand EMR Security Configuration

**Objective**: Learn about EMR security configuration structure.

**Security Configuration Components**:
1. **Encryption at Rest**:
   - EBS encryption (local disk)
   - S3 encryption (SSE-KMS)
   
2. **Encryption in Transit**:
   - Node-to-node encryption
   - TLS for HTTPS connections
   - Certificate requirements

**Actions**:
Review `terraform/modules/security-config/main.tf`

**No verification needed** - understanding security configuration

---

### Step 43: Generate Self-Signed Certificates

**Objective**: Create certificates for in-transit encryption.

**Actions**:
```bash
cd scripts/setup
python3 generate-certificates.py --output ../../config/certificates
```

This generates:
- `privateKey.pem`: Private key
- `certificateChain.pem`: Certificate chain
- `trustedCertificates.pem`: CA certificates

**Verification**:
```bash
ls -la config/certificates/
openssl x509 -in config/certificates/certificateChain.pem -text -noout
```

**Expected Output**: Three PEM files created, certificate details displayed

---

### Step 44: Upload Certificates to S3

**Objective**: Store certificates in S3 for EMR access.

**Actions**:
```bash
# Create certificates folder in scripts bucket
aws s3api put-object \
  --bucket emr-encryption-dev-scripts-$(aws sts get-caller-identity --query Account --output text) \
  --key certificates/

# Upload certificates
aws s3 cp config/certificates/ \
  s3://emr-encryption-dev-scripts-$(aws sts get-caller-identity --query Account --output text)/certificates/ \
  --recursive \
  --sse aws:kms \
  --sse-kms-key-id $(terraform output -raw kms_key_id)
```

**Verification**:
```bash
aws s3 ls s3://emr-encryption-dev-scripts-ACCOUNT_ID/certificates/
```

**Expected Output**: Three PEM files in S3

---

### Step 45: Create Security Configuration Module

**Objective**: Configure EMR security settings.

**Actions**:
Add to `terraform/environments/dev/main.tf`:
```hcl
module "security_config" {
  source = "../../modules/security-config"

  project_name = var.project_name
  environment  = var.environment
  
  # Encryption at rest
  enable_at_rest_encryption = true
  kms_key_id               = module.kms.key_id
  
  # Encryption in transit
  enable_in_transit_encryption = true
  certificates_s3_bucket       = module.s3.scripts_bucket_name
  certificates_s3_prefix       = "certificates/"
  
  tags = var.tags
}
```

**Verification**: Configuration syntax is correct

---

### Step 46: Plan and Apply Security Configuration

**Objective**: Create EMR security configuration.

**Actions**:
```bash
terraform plan -target=module.security_config
terraform apply -target=module.security_config
```

**Verification**:
```bash
aws emr describe-security-configuration \
  --name emr-encryption-dev-security-config
```

**Expected Output**: Security configuration details with encryption settings

---

### Step 47: Create EMR Cluster Module Configuration

**Objective**: Configure the EMR cluster module.

**Actions**:
Add to `terraform/environments/dev/main.tf`:
```hcl
module "emr" {
  source = "../../modules/emr"

  project_name = var.project_name
  environment  = var.environment
  
  # Network
  subnet_id          = module.vpc.private_subnet_id
  master_security_group_id = module.vpc.emr_master_security_group_id
  slave_security_group_id  = module.vpc.emr_core_security_group_id
  
  # Cluster configuration
  release_label         = var.emr_release_label
  applications          = ["Hadoop", "Spark", "Hive", "Pig"]
  master_instance_type  = var.master_instance_type
  core_instance_type    = var.core_instance_type
  core_instance_count   = var.core_instance_count
  
  # Storage
  logs_bucket = module.s3.logs_bucket_name
  
  # Security
  security_configuration = module.security_config.security_configuration_name
  key_name              = var.key_pair_name
  
  # IAM
  service_role          = aws_iam_role.emr_service_role.arn
  instance_profile      = aws_iam_instance_profile.emr_ec2_instance_profile.arn
  
  # Auto-termination (for dev)
  auto_terminate = true
  
  tags = var.tags
}
```

**Verification**: Configuration syntax is correct

---

### Step 48: Validate Terraform Configuration

**Objective**: Check all Terraform files for errors.

**Actions**:
```bash
cd terraform/environments/dev

# Format Terraform files
terraform fmt -recursive

# Validate configuration
terraform validate

# Check for issues
terraform plan
```

**Verification**:
All validations pass without errors.

**Expected Output**: 
```
Success! The configuration is valid.
```

---

### Step 49: Review Complete Infrastructure Plan

**Objective**: Understand all resources to be created.

**Actions**:
```bash
terraform plan -out=tfplan

# Review the plan
terraform show tfplan
```

**Resources to be Created**:
- 1 KMS key + alias
- 1 VPC + networking components
- 3 S3 buckets
- 5 Security groups
- 3 IAM roles
- 1 Security configuration
- 1 EMR cluster (if not already applied)

**Verification**: Review counts match expected

---

### Step 50: Validate Intermediate Setup

**Objective**: Confirm all intermediate steps completed.

**Checklist**:
```bash
python3 scripts/validation/validate-infrastructure.py --environment dev
```

**Expected Output**:
```
✓ Terraform backend configured
✓ KMS key created and accessible
✓ VPC and networking configured
✓ S3 buckets created with encryption
✓ IAM roles properly configured
✓ Security configuration created
✓ Certificates uploaded to S3
✓ All Terraform configurations valid

Intermediate level complete! Ready for advanced deployment.
```

**Troubleshooting**: If any check fails, review the corresponding step.

---

## Intermediate Level Complete! 🎉

Congratulations! You've completed the intermediate level. You now have:
- ✅ Terraform infrastructure modules created
- ✅ KMS encryption keys configured
- ✅ Network infrastructure deployed
- ✅ S3 storage with encryption
- ✅ IAM roles and permissions
- ✅ Security configuration ready
- ✅ Certificates prepared

**Next Steps**: Proceed to [Advanced Level (Steps 51-75)](../advanced/steps-51-75.md) to deploy and configure the EMR cluster with full encryption.

---

## Quick Reference Commands

```bash
# Terraform workflow
terraform init
terraform plan
terraform apply
terraform destroy

# Check infrastructure
aws kms list-keys
aws ec2 describe-vpcs
aws s3 ls
aws iam list-roles

# Terraform state
terraform state list
terraform state show module.kms.aws_kms_key.main
terraform output
```
