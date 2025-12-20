# Beginner Level: Steps 1-25

## Foundation and Setup (Novice to Comfortable Beginner)

---

### Step 1: Verify AWS Account Access

**Objective**: Confirm you have an active AWS account with appropriate permissions.

**Actions**:
1. Log into the AWS Management Console at https://console.aws.amazon.com
2. Navigate to IAM (Identity and Access Management)
3. Verify your user has permissions for: EC2, EMR, S3, KMS, VPC

**Verification**:
```bash
aws sts get-caller-identity
```

**Expected Output**: Your account ID, user ARN, and user ID

---

### Step 2: Install AWS CLI

**Objective**: Install the AWS Command Line Interface on your local machine.

**Actions**:

**For Linux/Mac**:
```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

**For Windows**:
Download and run the AWS CLI MSI installer from https://aws.amazon.com/cli/

**Verification**:
```bash
aws --version
```

**Expected Output**: `aws-cli/2.x.x ...`

---

### Step 3: Configure AWS CLI Credentials

**Objective**: Set up AWS credentials for programmatic access.

**Actions**:
1. In AWS Console, go to IAM → Users → Your User → Security Credentials
2. Create an Access Key
3. Save the Access Key ID and Secret Access Key securely
4. Run configuration command:

```bash
aws configure
```

Enter your:
- AWS Access Key ID
- AWS Secret Access Key
- Default region (e.g., `us-east-1`)
- Default output format (use `json`)

**Verification**:
```bash
aws s3 ls
```

**Expected Output**: List of S3 buckets (or empty if no buckets exist)

---

### Step 4: Install Python 3.8+

**Objective**: Install Python for running automation scripts.

**Actions**:

**For Linux**:
```bash
sudo apt update
sudo apt install python3.8 python3-pip python3-venv -y
```

**For Mac**:
```bash
brew install python@3.8
```

**For Windows**:
Download from https://www.python.org/downloads/

**Verification**:
```bash
python3 --version
pip3 --version
```

**Expected Output**: Python 3.8+ and pip version

---

### Step 5: Install Terraform

**Objective**: Install Terraform for Infrastructure as Code.

**Actions**:

**For Linux**:
```bash
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/
```

**For Mac**:
```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

**For Windows**:
Download from https://www.terraform.io/downloads

**Verification**:
```bash
terraform version
```

**Expected Output**: Terraform v1.6.0 or higher

---

### Step 6: Clone the Repository

**Objective**: Get the project code on your local machine.

**Actions**:
```bash
git clone https://github.com/iotda-ol/dea-c01-emr-cluster-encryption-at-rest-in-transit-using-kms-and-pem-files.git
cd dea-c01-emr-cluster-encryption-at-rest-in-transit-using-kms-and-pem-files
```

**Verification**:
```bash
ls -la
```

**Expected Output**: Project directory structure

---

### Step 7: Set Up Python Virtual Environment

**Objective**: Create isolated Python environment for the project.

**Actions**:
```bash
cd python
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

**Verification**:
```bash
which python  # On Windows: where python
```

**Expected Output**: Path pointing to venv directory

---

### Step 8: Install Python Dependencies

**Objective**: Install required Python packages.

**Actions**:
```bash
pip install --upgrade pip
pip install -r requirements.txt
```

**Verification**:
```bash
pip list
```

**Expected Output**: List of installed packages including boto3, cryptography, etc.

---

### Step 9: Understand AWS Regions

**Objective**: Learn about AWS regions and availability zones.

**Key Concepts**:
- **Region**: Geographic area with multiple availability zones (e.g., us-east-1)
- **Availability Zone**: Isolated datacenter within a region (e.g., us-east-1a)

**Actions**:
```bash
aws ec2 describe-regions --output table
```

**Expected Output**: Table of available AWS regions

**Decision**: Choose a region close to your users (we'll use `us-east-1` for examples)

---

### Step 10: Understand Amazon EMR Basics

**Objective**: Learn what Amazon EMR is and its use cases.

**Key Concepts**:
- **EMR**: Elastic MapReduce - managed Hadoop framework
- **Use Cases**: Big data processing, ETL, machine learning, log analysis
- **Components**: Master node, core nodes, task nodes

**Actions**:
1. Read AWS EMR documentation: https://docs.aws.amazon.com/emr/
2. Review the architecture diagram in `docs/architecture/overview.md`

**No verification needed** - conceptual understanding

---

### Step 11: Understand Encryption at Rest

**Objective**: Learn what encryption at rest means.

**Key Concepts**:
- **Encryption at Rest**: Data encrypted when stored on disk
- **AWS KMS**: Key Management Service for managing encryption keys
- **S3 Encryption**: SSE-KMS (Server-Side Encryption with KMS)

**Actions**:
Review `docs/architecture/encryption-at-rest.md`

**No verification needed** - conceptual understanding

---

### Step 12: Understand Encryption in Transit

**Objective**: Learn what encryption in transit means.

**Key Concepts**:
- **Encryption in Transit**: Data encrypted during transmission
- **TLS/SSL**: Protocols for encrypting network traffic
- **PEM Files**: Certificate files for TLS configuration

**Actions**:
Review `docs/architecture/encryption-in-transit.md`

**No verification needed** - conceptual understanding

---

### Step 13: Understand AWS KMS

**Objective**: Learn how AWS Key Management Service works.

**Key Concepts**:
- **Customer Master Key (CMK)**: Encryption key managed by KMS
- **Data Keys**: Keys generated from CMK to encrypt data
- **Key Policies**: Control access to KMS keys

**Actions**:
1. Navigate to AWS Console → KMS
2. Explore the default AWS managed keys
3. Read key policy examples

**Verification**:
```bash
aws kms list-keys
```

**Expected Output**: List of KMS keys in your account

---

### Step 14: Understand S3 Bucket Basics

**Objective**: Learn about S3 storage for EMR data.

**Key Concepts**:
- **Bucket**: Container for objects (files)
- **Object**: File stored in S3
- **Bucket Policies**: Control access to buckets

**Actions**:
1. Navigate to AWS Console → S3
2. Review existing buckets (if any)
3. Understand bucket naming rules

**Verification**:
```bash
aws s3 ls
```

**Expected Output**: List of your S3 buckets

---

### Step 15: Understand VPC Basics

**Objective**: Learn about Virtual Private Cloud networking.

**Key Concepts**:
- **VPC**: Isolated network in AWS
- **Subnets**: Network segments within VPC (public/private)
- **Security Groups**: Virtual firewalls for EC2 instances

**Actions**:
1. Navigate to AWS Console → VPC
2. Review the default VPC
3. Explore subnet configuration

**Verification**:
```bash
aws ec2 describe-vpcs
```

**Expected Output**: List of VPCs in your account

---

### Step 16: Review Project Structure

**Objective**: Understand the organization of this project.

**Project Structure**:
```
.
├── docs/                    # Documentation
├── terraform/               # Infrastructure as Code
│   ├── modules/            # Reusable Terraform modules
│   └── environments/       # Environment-specific configs
├── python/                  # Python utilities
│   ├── src/                # Source code
│   └── tests/              # Test files
├── scripts/                 # Automation scripts
└── config/                  # Configuration templates
```

**Actions**:
```bash
tree -L 2
```

**Expected Output**: Directory tree matching above structure

---

### Step 17: Understand Terraform Basics

**Objective**: Learn fundamental Terraform concepts.

**Key Concepts**:
- **Provider**: Plugin for managing resources (e.g., AWS)
- **Resource**: Infrastructure component (e.g., EC2 instance)
- **Module**: Reusable Terraform code
- **State**: Current infrastructure state

**Actions**:
1. Review `terraform/modules/README.md`
2. Examine a simple module like `terraform/modules/kms/`

**No verification needed** - conceptual understanding

---

### Step 18: Set Up AWS Budget Alert (Optional but Recommended)

**Objective**: Avoid unexpected AWS charges.

**Actions**:
1. Go to AWS Console → Billing → Budgets
2. Click "Create budget"
3. Choose "Cost budget"
4. Set monthly budget (e.g., $50)
5. Configure email alerts at 80% and 100%

**Verification**: You'll receive a confirmation email

---

### Step 19: Understand EMR Security Configuration

**Objective**: Learn how EMR security configurations work.

**Key Concepts**:
- **Security Configuration**: EMR-specific security settings
- **Encryption Settings**: At-rest and in-transit encryption
- **Authentication**: Kerberos, LDAP integration options

**Actions**:
Review `docs/architecture/security-configuration.md`

**No verification needed** - conceptual understanding

---

### Step 20: Understand IAM Roles for EMR

**Objective**: Learn about IAM roles required for EMR.

**Key Concepts**:
- **EMR Service Role**: Allows EMR to call AWS services
- **EC2 Instance Profile**: Role for EC2 instances in cluster
- **Auto Scaling Role**: For automatic cluster scaling

**Actions**:
1. Navigate to AWS Console → IAM → Roles
2. Search for "EMR" to see default roles
3. Review the permissions policies

**Verification**:
```bash
aws iam list-roles | grep EMR
```

**Expected Output**: List of EMR-related roles

---

### Step 21: Create SSH Key Pair

**Objective**: Create SSH key for accessing EMR cluster nodes.

**Actions**:
```bash
aws ec2 create-key-pair \
  --key-name emr-cluster-key \
  --query 'KeyMaterial' \
  --output text > ~/.ssh/emr-cluster-key.pem

chmod 400 ~/.ssh/emr-cluster-key.pem
```

**Verification**:
```bash
ls -la ~/.ssh/emr-cluster-key.pem
aws ec2 describe-key-pairs --key-name emr-cluster-key
```

**Expected Output**: Key file exists with 400 permissions, key pair details

---

### Step 22: Understand Terraform State

**Objective**: Learn how Terraform tracks infrastructure.

**Key Concepts**:
- **State File**: Records current infrastructure state
- **Remote State**: Store state in S3 for team collaboration
- **State Locking**: Prevent concurrent modifications

**Actions**:
Review `docs/architecture/terraform-state.md`

**No verification needed** - conceptual understanding

---

### Step 23: Set Up Environment Variables

**Objective**: Configure environment-specific variables.

**Actions**:
```bash
# Create .env file (don't commit this!)
cat > .env << 'EOF'
AWS_REGION=us-east-1
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
PROJECT_NAME=emr-encryption
ENVIRONMENT=dev
EOF

source .env
```

**Verification**:
```bash
echo $AWS_REGION
echo $PROJECT_NAME
```

**Expected Output**: Your configured values

---

### Step 24: Understand Cost Considerations

**Objective**: Learn about AWS costs for this project.

**Key Cost Factors**:
- **EMR Cluster**: EC2 instance costs + EMR service cost
- **S3 Storage**: Storage and request costs
- **KMS**: Key operations (first 20,000 free per month)
- **Data Transfer**: Outbound data transfer costs

**Actions**:
1. Review AWS Pricing Calculator: https://calculator.aws/
2. Estimate costs for dev environment
3. Review `docs/architecture/cost-optimization.md`

**No verification needed** - awareness building

---

### Step 25: Validate Beginner Setup

**Objective**: Confirm all beginner prerequisites are met.

**Checklist**:
```bash
# Run this validation script
python3 scripts/setup/validate-prerequisites.py
```

**Expected Output**:
```
✓ AWS CLI installed and configured
✓ Python 3.8+ installed
✓ Terraform installed
✓ Repository cloned
✓ Python dependencies installed
✓ SSH key created
✓ Environment variables set

All beginner prerequisites met! Ready for intermediate level.
```

**Troubleshooting**: If any check fails, review the corresponding step above.

---

## Beginner Level Complete! 🎉

Congratulations! You've completed the beginner level. You now have:
- ✅ Development environment set up
- ✅ AWS CLI configured
- ✅ Understanding of AWS basics
- ✅ Project structure knowledge
- ✅ Basic security awareness

**Next Steps**: Proceed to [Intermediate Level (Steps 26-50)](../intermediate/steps-26-50.md) to start building infrastructure with Terraform.

---

## Quick Reference Commands

```bash
# Activate Python environment
source python/venv/bin/activate

# Check AWS credentials
aws sts get-caller-identity

# Verify Terraform
terraform version

# List AWS resources
aws s3 ls
aws ec2 describe-vpcs
aws kms list-keys
```
