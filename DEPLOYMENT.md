# Deployment Guide

This guide provides step-by-step instructions for deploying the secure EMR cluster.

## Prerequisites

Ensure you have the following before starting:

- [ ] AWS Account with appropriate permissions
- [ ] AWS CLI configured with credentials
- [ ] Terraform >= 1.0 installed
- [ ] Python >= 3.8 installed
- [ ] Existing VPC and subnet in AWS
- [ ] (Optional) EC2 key pair for SSH access

## Step-by-Step Deployment

### Step 1: Clone the Repository

```bash
git clone https://github.com/iotda-ol/dea-c01-emr-cluster-encryption-at-rest-in-transit-using-kms-and-pem-files.git
cd dea-c01-emr-cluster-encryption-at-rest-in-transit-using-kms-and-pem-files
```

### Step 2: Install Python Dependencies

```bash
# Create a virtual environment (recommended)
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
```

### Step 3: Generate Certificates

Generate the PEM certificates required for in-transit encryption:

```bash
python scripts/generate_certificates.py \
  --output-dir ./certificates \
  --common-name "*.compute.internal" \
  --organization "My Organization" \
  --validity-days 365 \
  --key-size 2048
```

**Expected Output:**
```
Output directory: ./certificates
Generating 2048-bit RSA private key...
Generating self-signed certificate for *.compute.internal...
Saving private key to ./certificates/privateKey.pem...
Saving certificate to ./certificates/certificateChain.pem...
Creating certificate bundle at ./certificates/certificateBundle.zip...
Certificate generation completed successfully!
```

**Important:** Keep the `privateKey.pem` secure and do not commit it to version control.

### Step 4: Configure Terraform Variables

Create your Terraform variables file:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your configuration:

```hcl
# AWS Configuration
aws_region   = "us-east-1"
project_name = "my-emr-project"
environment  = "dev"

# Network Configuration (REQUIRED)
subnet_id = "subnet-xxxxxxxxx"  # Your subnet ID
vpc_id    = "vpc-xxxxxxxxx"     # Your VPC ID

# Access Control
allowed_cidr_blocks = ["10.0.0.0/8"]  # Allowed CIDR blocks

# Optional: SSH Access
key_name = "my-ec2-keypair"  # Your EC2 key pair name

# EMR Configuration
emr_release_label       = "emr-6.15.0"
emr_master_instance_type = "m5.xlarge"
emr_core_instance_type   = "m5.xlarge"
emr_core_instance_count  = 2

# Security
enable_termination_protection = false  # Set to true for production

# Logging
log_retention_days = 90

# Tags
tags = {
  Owner      = "data-engineering-team"
  CostCenter = "engineering"
}
```

### Step 5: Initialize Terraform

Initialize Terraform and download required providers:

```bash
terraform init
```

**Expected Output:**
```
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 5.0"...
- Installing hashicorp/aws...
Terraform has been successfully initialized!
```

### Step 6: Review Terraform Plan

Review the resources that will be created:

```bash
terraform plan
```

Review the output carefully. You should see resources for:
- KMS key and alias
- S3 buckets (certificates and logs)
- IAM roles and policies (service role, EC2 role, autoscaling role)
- Security groups (master, slave, service)
- EMR security configuration
- EMR cluster

### Step 7: Apply Infrastructure (Initial)

Apply the Terraform configuration to create the S3 buckets and other resources:

```bash
terraform apply
```

Type `yes` when prompted.

**Note:** The EMR cluster may fail to start initially because the certificates need to be uploaded to S3 first.

### Step 8: Upload Certificates to S3

After the S3 bucket is created, upload the certificate bundle:

```bash
# Get the bucket name from Terraform output
BUCKET_NAME=$(terraform output -raw certificates_bucket_name)

# Upload certificates
python scripts/upload_certificates.py \
  --bucket-name "$BUCKET_NAME" \
  --bundle-path ./certificates/certificateBundle.zip \
  --s3-prefix certificates \
  --aws-region us-east-1
```

**Expected Output:**
```
✓ Bucket 'my-project-dev-certificates-123456789012' exists and is accessible
✓ Bucket encryption: aws:kms
Uploading ./certificates/certificateBundle.zip to s3://my-project-dev-certificates-123456789012/certificates/certificateBundle.zip...
✓ Upload successful!
```

### Step 9: Verify Certificate Upload

Verify the certificate bundle is in S3:

```bash
aws s3 ls s3://$BUCKET_NAME/certificates/
```

You should see `certificateBundle.zip` listed.

### Step 10: Start EMR Cluster (If Failed)

If the EMR cluster failed to start in Step 7, restart it:

```bash
# If the cluster failed, apply again
terraform apply
```

Or manually start the cluster through the AWS Console or CLI.

### Step 11: Verify Deployment

Check the status of your EMR cluster:

```bash
# Get cluster ID
CLUSTER_ID=$(terraform output -raw emr_cluster_id)

# Check cluster status
aws emr describe-cluster --cluster-id $CLUSTER_ID

# View all outputs
terraform output
```

### Step 12: Access EMR Cluster

#### Via AWS Console

1. Navigate to EMR in AWS Console
2. Find your cluster by name or ID
3. View cluster details, monitoring, and logs

#### Via SSH (if key_name was provided)

```bash
# Get master node DNS
MASTER_DNS=$(terraform output -raw emr_cluster_master_public_dns)

# SSH to master node
ssh -i ~/.ssh/your-key.pem hadoop@$MASTER_DNS
```

#### Via AWS CLI

```bash
# List running steps
aws emr list-steps --cluster-id $CLUSTER_ID

# Add a step (example: Spark job)
aws emr add-steps \
  --cluster-id $CLUSTER_ID \
  --steps Type=Spark,Name="Example Spark Job",ActionOnFailure=CONTINUE,Args=[--class,org.apache.spark.examples.SparkPi,/usr/lib/spark/examples/jars/spark-examples.jar,10]
```

## Verification Checklist

After deployment, verify the following:

- [ ] KMS key is created and enabled
- [ ] S3 buckets are created with encryption enabled
- [ ] IAM roles are created with correct policies
- [ ] Security groups have correct rules
- [ ] EMR security configuration exists
- [ ] EMR cluster is in "WAITING" state
- [ ] Certificates are uploaded to S3
- [ ] Logs are being written to S3
- [ ] CloudWatch metrics are available
- [ ] Cluster applications (Spark, Hadoop, Hive) are accessible

## Troubleshooting

### Issue: Terraform Apply Fails

**Error:** "Error creating EMR Cluster: ValidationException: The security configuration requires a valid S3 object for TLS certificates"

**Solution:**
1. Ensure certificates are uploaded to S3
2. Verify the S3 path in `emr_security_config.tf` matches the upload location
3. Check bucket permissions

### Issue: Certificate Upload Fails

**Error:** "Error: Access denied to bucket"

**Solution:**
1. Verify AWS credentials: `aws sts get-caller-identity`
2. Check IAM permissions for S3 PutObject
3. Ensure bucket exists: `aws s3 ls s3://$BUCKET_NAME`

### Issue: SSH Connection Refused

**Possible Causes:**
1. Security group not allowing SSH from your IP
2. EC2 key pair not specified
3. Cluster in private subnet without bastion host

**Solution:**
1. Update `allowed_cidr_blocks` in terraform.tfvars
2. Set `key_name` variable
3. Use AWS Systems Manager Session Manager or bastion host

### Issue: Cluster Fails to Start

**Check:**
1. EMR logs in S3: `aws s3 ls s3://$LOGS_BUCKET/emr-logs/`
2. CloudWatch logs for error messages
3. Subnet has internet access (for downloading packages)
4. IAM roles have correct permissions

## Post-Deployment Tasks

### 1. Configure Monitoring

Set up CloudWatch alarms:

```bash
# Example: Cluster state alarm
aws cloudwatch put-metric-alarm \
  --alarm-name emr-cluster-failed \
  --alarm-description "Alert if EMR cluster fails" \
  --metric-name IsIdle \
  --namespace AWS/ElasticMapReduce \
  --statistic Average \
  --period 300 \
  --evaluation-periods 1 \
  --threshold 0 \
  --comparison-operator LessThanThreshold \
  --dimensions Name=JobFlowId,Value=$CLUSTER_ID
```

### 2. Configure Backup

Enable automated backups for:
- S3 buckets (versioning already enabled)
- EMR configurations (stored in version control)
- Certificate rotation schedule

### 3. Document Custom Configurations

Document any custom configurations:
- Custom bootstrap actions
- Application-specific settings
- Network configurations
- Security exceptions

### 4. Set Up Access Control

Configure team access:
- Create IAM policies for team members
- Set up SSO if available
- Configure least-privilege access

### 5. Enable Additional Logging

Consider enabling:
- CloudTrail for API auditing
- VPC Flow Logs for network monitoring
- S3 access logging

## Cleanup

To destroy all resources:

```bash
# Warning: This will delete all resources including data in S3
terraform destroy
```

If you want to preserve logs:

```bash
# Download logs before destroying
aws s3 sync s3://$LOGS_BUCKET ./backup-logs/

# Then destroy
terraform destroy
```

## Next Steps

- Review [SECURITY.md](SECURITY.md) for security best practices
- Set up monitoring dashboards
- Configure certificate rotation
- Plan for cluster scaling
- Document operational procedures

## Support

For issues or questions:
- Check AWS EMR documentation
- Review Terraform AWS provider documentation
- Open an issue in the repository
- Contact AWS Support for AWS-specific issues
