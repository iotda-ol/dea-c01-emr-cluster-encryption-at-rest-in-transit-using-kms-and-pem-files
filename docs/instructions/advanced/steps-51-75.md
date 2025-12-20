# Advanced Level: Steps 51-75

## EMR Deployment and Security Implementation (Intermediate to Advanced)

---

### Step 51: Deploy Complete EMR Infrastructure

**Objective**: Deploy the full EMR cluster with encryption.

**Actions**:
```bash
cd terraform/environments/dev

# Final plan review
terraform plan

# Apply all infrastructure
terraform apply
```

Type `yes` when prompted.

**Verification**:
```bash
# Get cluster ID
terraform output emr_cluster_id

# Check cluster status
aws emr describe-cluster --cluster-id $(terraform output -raw emr_cluster_id)
```

**Expected Output**: Cluster status shows "STARTING" or "RUNNING"

---

### Step 52: Monitor EMR Cluster Startup

**Objective**: Watch cluster initialization and verify successful start.

**Actions**:
```bash
# Monitor cluster status
watch -n 10 'aws emr describe-cluster --cluster-id $(terraform output -raw emr_cluster_id) --query "Cluster.Status.State"'

# Or use Python script
python3 python/src/monitoring/cluster_monitor.py --cluster-id $(terraform output -raw emr_cluster_id)
```

**Timeline**:
- Bootstrap: 5-10 minutes
- Applications install: 5-15 minutes
- Total: 10-25 minutes

**Verification**:
Status changes: STARTING → BOOTSTRAPPING → RUNNING

**Expected Output**: Cluster reaches "RUNNING" state

---

### Step 53: Verify Encryption at Rest

**Objective**: Confirm data is encrypted at rest.

**Actions**:
```bash
# Check EBS encryption
python3 python/src/encryption/verify_at_rest.py \
  --cluster-id $(terraform output -raw emr_cluster_id)

# Manual verification
aws ec2 describe-volumes \
  --filters "Name=tag:aws:elasticmapreduce:job-flow-id,Values=$(terraform output -raw emr_cluster_id)" \
  --query 'Volumes[*].[VolumeId,Encrypted,KmsKeyId]' \
  --output table
```

**Verification**:
- All EBS volumes show Encrypted=true
- KMS Key ID matches your CMK

**Expected Output**: All volumes encrypted with KMS key

---

### Step 54: Verify Encryption in Transit

**Objective**: Confirm TLS encryption is active.

**Actions**:
```bash
# Verify security configuration
aws emr describe-security-configuration \
  --name $(terraform output -raw security_configuration_name) \
  | jq '.SecurityConfiguration | fromjson | .EncryptionConfiguration.EnableInTransitEncryption'

# Check certificate deployment
python3 python/src/encryption/verify_in_transit.py \
  --cluster-id $(terraform output -raw emr_cluster_id)
```

**Verification**:
- EnableInTransitEncryption = true
- Certificates deployed to cluster nodes

**Expected Output**: In-transit encryption enabled and configured

---

### Step 55: Access EMR Master Node

**Objective**: SSH into the master node for verification.

**Actions**:
```bash
# Get master node public DNS
MASTER_DNS=$(aws emr describe-cluster \
  --cluster-id $(terraform output -raw emr_cluster_id) \
  --query 'Cluster.MasterPublicDnsName' \
  --output text)

# SSH to master node
ssh -i ~/.ssh/emr-cluster-key.pem hadoop@${MASTER_DNS}
```

**Verification**:
Successfully connected to master node.

**Expected Output**: Hadoop user prompt on master node

---

### Step 56: Verify Hadoop Configuration

**Objective**: Check Hadoop encryption settings on the cluster.

**Actions** (on master node):
```bash
# Check Hadoop encryption settings
hadoop fs -ls /

# Verify HDFS encryption zones
hdfs crypto -listZones

# Check core-site.xml for encryption
cat /etc/hadoop/conf/core-site.xml | grep -A5 encryption
```

**Verification**:
- HDFS accessible
- Encryption zones configured (if applicable)
- Encryption properties set

**Expected Output**: Hadoop configured with encryption settings

---

### Step 57: Test S3 Encryption Integration

**Objective**: Verify S3 access with KMS encryption.

**Actions** (on master node):
```bash
# Create test file
echo "Test data for encryption" > test.txt

# Upload to S3 with encryption
aws s3 cp test.txt s3://emr-encryption-dev-data-ACCOUNT_ID/test/test.txt

# Verify encryption
aws s3api head-object \
  --bucket emr-encryption-dev-data-ACCOUNT_ID \
  --key test/test.txt \
  | jq '.ServerSideEncryption, .SSEKMSKeyId'

# Read back
hadoop fs -cat s3://emr-encryption-dev-data-ACCOUNT_ID/test/test.txt
```

**Verification**:
- File uploaded successfully
- ServerSideEncryption = "aws:kms"
- KMS Key ID matches your CMK
- File readable from Hadoop

**Expected Output**: Data encrypted with KMS in S3

---

### Step 58: Run Spark Job with Encrypted Data

**Objective**: Execute Spark job to verify encryption doesn't impact processing.

**Actions** (on master node):
```bash
# Start Spark shell
spark-shell

# In Spark shell:
val data = spark.read.text("s3://emr-encryption-dev-data-ACCOUNT_ID/test/test.txt")
data.show()
data.count()

# Write encrypted output
data.write.text("s3://emr-encryption-dev-data-ACCOUNT_ID/test/output/")

:quit
```

**Verification**:
```bash
# Verify output is encrypted
aws s3api head-object \
  --bucket emr-encryption-dev-data-ACCOUNT_ID \
  --key test/output/part-00000 \
  | jq '.ServerSideEncryption'
```

**Expected Output**: Spark processes data, output encrypted

---

### Step 59: Configure Spark Encryption Settings

**Objective**: Enable Spark-specific encryption features.

**Actions**:
Create `config/templates/spark-encryption.conf`:
```properties
# Spark SSL/TLS Configuration
spark.ssl.enabled=true
spark.ssl.protocol=TLSv1.2
spark.ssl.enabledAlgorithms=TLS_RSA_WITH_AES_128_CBC_SHA,TLS_RSA_WITH_AES_256_CBC_SHA

# Spark I/O encryption
spark.io.encryption.enabled=true
spark.network.crypto.enabled=true

# Spark authentication
spark.authenticate=true
spark.authenticate.secret=YOUR_SECRET_HERE

# Spark event log encryption
spark.eventLog.enabled=true
spark.eventLog.dir=s3://emr-encryption-dev-logs-ACCOUNT_ID/spark-logs/
```

**Verification**:
```bash
# Apply configuration
python3 python/src/deployment/apply_spark_config.py \
  --cluster-id $(terraform output -raw emr_cluster_id) \
  --config config/templates/spark-encryption.conf
```

**Expected Output**: Spark encryption configured

---

### Step 60: Test Hive with Encryption

**Objective**: Verify Hive works with encrypted S3.

**Actions** (on master node):
```bash
# Start Hive
hive

# In Hive:
CREATE DATABASE IF NOT EXISTS encrypted_db
LOCATION 's3://emr-encryption-dev-data-ACCOUNT_ID/hive/encrypted_db/';

USE encrypted_db;

CREATE TABLE test_table (
  id INT,
  message STRING
)
STORED AS PARQUET
LOCATION 's3://emr-encryption-dev-data-ACCOUNT_ID/hive/test_table/';

INSERT INTO test_table VALUES (1, 'Encrypted data');

SELECT * FROM test_table;

quit;
```

**Verification**:
```bash
# Check table data encryption
aws s3api head-object \
  --bucket emr-encryption-dev-data-ACCOUNT_ID \
  --key hive/test_table/ \
  | jq '.ServerSideEncryption'
```

**Expected Output**: Hive table data encrypted in S3

---

### Step 61: Implement CloudWatch Monitoring

**Objective**: Set up monitoring for the EMR cluster.

**Actions**:
```bash
# Enable detailed monitoring
python3 python/src/monitoring/setup_cloudwatch.py \
  --cluster-id $(terraform output -raw emr_cluster_id) \
  --enable-detailed-monitoring

# Create custom dashboard
python3 python/src/monitoring/create_dashboard.py \
  --cluster-id $(terraform output -raw emr_cluster_id) \
  --dashboard-name emr-encryption-dev
```

**Verification**:
```bash
# Check CloudWatch dashboard
aws cloudwatch list-dashboards | grep emr-encryption-dev

# View metrics
aws cloudwatch list-metrics --namespace AWS/ElasticMapReduce
```

**Expected Output**: Dashboard created, metrics flowing

---

### Step 62: Configure CloudWatch Alarms

**Objective**: Set up alerts for cluster issues.

**Actions**:
```bash
# Create alarms for key metrics
python3 python/src/monitoring/create_alarms.py \
  --cluster-id $(terraform output -raw emr_cluster_id) \
  --sns-topic arn:aws:sns:us-east-1:ACCOUNT_ID:emr-alerts

# Alarms created for:
# - Master node health
# - Core node health
# - HDFS utilization > 80%
# - Failed job steps
```

**Verification**:
```bash
aws cloudwatch describe-alarms --alarm-name-prefix emr-encryption-dev
```

**Expected Output**: 4-6 alarms created

---

### Step 63: Implement Automated Backups

**Objective**: Set up S3 backup strategy.

**Actions**:
Create `terraform/environments/dev/backups.tf`:
```hcl
# S3 lifecycle rules for backups
resource "aws_s3_bucket_lifecycle_configuration" "data_backup" {
  bucket = module.s3.data_bucket_id

  rule {
    id     = "backup-transition"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }
  }
}

# Enable versioning for data protection
resource "aws_s3_bucket_versioning" "data_versioning" {
  bucket = module.s3.data_bucket_id
  
  versioning_configuration {
    status = "Enabled"
  }
}
```

**Verification**:
```bash
terraform apply
aws s3api get-bucket-lifecycle-configuration --bucket emr-encryption-dev-data-ACCOUNT_ID
```

**Expected Output**: Lifecycle rules active

---

### Step 64: Create Cluster Bootstrap Scripts

**Objective**: Automate cluster initialization.

**Actions**:
Create `scripts/deployment/bootstrap.sh`:
```bash
#!/bin/bash
# EMR Bootstrap Script

set -e

# Install additional packages
sudo yum install -y htop vim git

# Configure Python environment
sudo pip3 install boto3 pandas numpy

# Set up custom logging
mkdir -p /mnt/var/log/custom
chown hadoop:hadoop /mnt/var/log/custom

# Download custom configurations
aws s3 cp s3://emr-encryption-dev-scripts-ACCOUNT_ID/configs/ /home/hadoop/configs/ --recursive

# Set environment variables
echo "export EMR_CLUSTER_ID=$CLUSTER_ID" >> /home/hadoop/.bashrc
echo "export DATA_BUCKET=s3://emr-encryption-dev-data-ACCOUNT_ID" >> /home/hadoop/.bashrc

echo "Bootstrap complete!"
```

**Verification**:
Upload to S3 and test on new cluster.

---

### Step 65: Implement Cluster Auto-Scaling

**Objective**: Configure automatic scaling based on load.

**Actions**:
Add to `terraform/modules/emr/main.tf`:
```hcl
resource "aws_emr_instance_group" "task" {
  cluster_id     = aws_emr_cluster.main.id
  instance_type  = var.task_instance_type
  instance_count = var.task_instance_count_min
  name           = "Task Instance Group"

  autoscaling_policy = jsonencode({
    Constraints = {
      MinCapacity = var.task_instance_count_min
      MaxCapacity = var.task_instance_count_max
    }
    Rules = [
      {
        Name = "ScaleUpOnYARNMemory"
        Description = "Scale up when YARN memory is low"
        Action = {
          SimpleScalingPolicyConfiguration = {
            AdjustmentType = "CHANGE_IN_CAPACITY"
            ScalingAdjustment = 1
            CoolDown = 300
          }
        }
        Trigger = {
          CloudWatchAlarmDefinition = {
            ComparisonOperator = "LESS_THAN"
            EvaluationPeriods = 1
            MetricName = "YARNMemoryAvailablePercentage"
            Namespace = "AWS/ElasticMapReduce"
            Period = 300
            Statistic = "AVERAGE"
            Threshold = 20.0
            Unit = "PERCENT"
          }
        }
      },
      {
        Name = "ScaleDownOnYARNMemory"
        Description = "Scale down when YARN memory is high"
        Action = {
          SimpleScalingPolicyConfiguration = {
            AdjustmentType = "CHANGE_IN_CAPACITY"
            ScalingAdjustment = -1
            CoolDown = 300
          }
        }
        Trigger = {
          CloudWatchAlarmDefinition = {
            ComparisonOperator = "GREATER_THAN"
            EvaluationPeriods = 1
            MetricName = "YARNMemoryAvailablePercentage"
            Namespace = "AWS/ElasticMapReduce"
            Period = 300
            Statistic = "AVERAGE"
            Threshold = 80.0
            Unit = "PERCENT"
          }
        }
      }
    ]
  })
}
```

**Verification**:
```bash
terraform apply
aws emr describe-cluster --cluster-id $(terraform output -raw emr_cluster_id) | jq '.Cluster.InstanceGroups'
```

**Expected Output**: Task instance group with auto-scaling configured

---

### Step 66: Create Python Deployment Automation

**Objective**: Build Python tool for cluster deployment.

**Actions**:
Create `python/src/deployment/deploy_cluster.py`:
```python
#!/usr/bin/env python3
"""
EMR Cluster Deployment Automation
"""
import argparse
import boto3
import json
import time
from typing import Dict, Any

class EMRDeployer:
    def __init__(self, region: str, environment: str):
        self.emr = boto3.client('emr', region_name=region)
        self.environment = environment
        
    def deploy_cluster(self, config: Dict[str, Any]) -> str:
        """Deploy EMR cluster with encryption"""
        response = self.emr.run_job_flow(**config)
        cluster_id = response['JobFlowId']
        print(f"Cluster created: {cluster_id}")
        return cluster_id
    
    def wait_for_cluster(self, cluster_id: str, timeout: int = 1800):
        """Wait for cluster to be ready"""
        start_time = time.time()
        while time.time() - start_time < timeout:
            response = self.emr.describe_cluster(ClusterId=cluster_id)
            state = response['Cluster']['Status']['State']
            print(f"Cluster state: {state}")
            
            if state == 'WAITING':
                print("Cluster is ready!")
                return True
            elif state in ['TERMINATED', 'TERMINATED_WITH_ERRORS']:
                raise Exception(f"Cluster failed: {state}")
            
            time.sleep(30)
        
        raise TimeoutError("Cluster deployment timeout")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--config', required=True, help='Configuration file')
    parser.add_argument('--region', default='us-east-1')
    parser.add_argument('--environment', default='dev')
    args = parser.parse_args()
    
    with open(args.config) as f:
        config = json.load(f)
    
    deployer = EMRDeployer(args.region, args.environment)
    cluster_id = deployer.deploy_cluster(config)
    deployer.wait_for_cluster(cluster_id)
```

**Verification**: Test deployment script

---

### Step 67: Create Certificate Rotation Script

**Objective**: Automate certificate renewal process.

**Actions**:
Create `python/src/certificate_manager/rotate_certificates.py`:
```python
#!/usr/bin/env python3
"""
Certificate Rotation for EMR Clusters
"""
import argparse
import boto3
from cryptography import x509
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import rsa
from datetime import datetime, timedelta

class CertificateManager:
    def __init__(self, s3_bucket: str, s3_prefix: str):
        self.s3 = boto3.client('s3')
        self.bucket = s3_bucket
        self.prefix = s3_prefix
    
    def generate_certificate(self, days_valid: int = 365):
        """Generate new self-signed certificate"""
        # Generate private key
        private_key = rsa.generate_private_key(
            public_exponent=65537,
            key_size=2048
        )
        
        # Generate certificate
        subject = issuer = x509.Name([
            x509.NameAttribute(x509.oid.NameOID.COUNTRY_NAME, "US"),
            x509.NameAttribute(x509.oid.NameOID.ORGANIZATION_NAME, "EMR Encryption"),
            x509.NameAttribute(x509.oid.NameOID.COMMON_NAME, "emr.internal"),
        ])
        
        cert = x509.CertificateBuilder().subject_name(
            subject
        ).issuer_name(
            issuer
        ).public_key(
            private_key.public_key()
        ).serial_number(
            x509.random_serial_number()
        ).not_valid_before(
            datetime.utcnow()
        ).not_valid_after(
            datetime.utcnow() + timedelta(days=days_valid)
        ).sign(private_key, hashes.SHA256())
        
        return private_key, cert
    
    def upload_to_s3(self, private_key, cert):
        """Upload certificates to S3"""
        # Serialize and upload
        private_pem = private_key.private_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PrivateFormat.PKCS8,
            encryption_algorithm=serialization.NoEncryption()
        )
        
        cert_pem = cert.public_bytes(serialization.Encoding.PEM)
        
        self.s3.put_object(
            Bucket=self.bucket,
            Key=f"{self.prefix}privateKey.pem",
            Body=private_pem,
            ServerSideEncryption='aws:kms'
        )
        
        self.s3.put_object(
            Bucket=self.bucket,
            Key=f"{self.prefix}certificateChain.pem",
            Body=cert_pem,
            ServerSideEncryption='aws:kms'
        )
        
        print("Certificates uploaded to S3")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--bucket', required=True)
    parser.add_argument('--prefix', default='certificates/')
    args = parser.parse_args()
    
    manager = CertificateManager(args.bucket, args.prefix)
    private_key, cert = manager.generate_certificate()
    manager.upload_to_s3(private_key, cert)
```

**Verification**: Test certificate generation

---

### Step 68: Implement Encryption Verification Tool

**Objective**: Automated testing of encryption settings.

**Actions**:
Create `python/src/encryption/verify_encryption.py`:
```python
#!/usr/bin/env python3
"""
Comprehensive Encryption Verification
"""
import boto3
import argparse
from typing import List, Dict

class EncryptionVerifier:
    def __init__(self, cluster_id: str, region: str):
        self.cluster_id = cluster_id
        self.emr = boto3.client('emr', region_name=region)
        self.ec2 = boto3.client('ec2', region_name=region)
        self.s3 = boto3.client('s3', region_name=region)
    
    def verify_ebs_encryption(self) -> bool:
        """Verify all EBS volumes are encrypted"""
        # Get cluster instances
        response = self.emr.list_instances(ClusterId=self.cluster_id)
        instance_ids = [i['Ec2InstanceId'] for i in response['Instances']]
        
        # Check volumes
        volumes = self.ec2.describe_volumes(
            Filters=[{'Name': 'attachment.instance-id', 'Values': instance_ids}]
        )['Volumes']
        
        all_encrypted = all(v['Encrypted'] for v in volumes)
        print(f"EBS Encryption: {'✓' if all_encrypted else '✗'}")
        print(f"  Total volumes: {len(volumes)}")
        print(f"  Encrypted: {sum(1 for v in volumes if v['Encrypted'])}")
        
        return all_encrypted
    
    def verify_s3_encryption(self, buckets: List[str]) -> bool:
        """Verify S3 buckets have encryption"""
        results = []
        for bucket in buckets:
            try:
                encryption = self.s3.get_bucket_encryption(Bucket=bucket)
                has_encryption = True
            except:
                has_encryption = False
            
            results.append(has_encryption)
            print(f"S3 Bucket {bucket}: {'✓' if has_encryption else '✗'}")
        
        return all(results)
    
    def verify_security_config(self) -> bool:
        """Verify cluster security configuration"""
        cluster = self.emr.describe_cluster(ClusterId=self.cluster_id)['Cluster']
        
        if 'SecurityConfiguration' not in cluster:
            print("Security Configuration: ✗ (Not set)")
            return False
        
        config_name = cluster['SecurityConfiguration']
        config = self.emr.describe_security_configuration(Name=config_name)
        
        config_json = json.loads(config['SecurityConfiguration'])
        
        at_rest = config_json.get('EncryptionConfiguration', {}).get('EnableAtRestEncryption', False)
        in_transit = config_json.get('EncryptionConfiguration', {}).get('EnableInTransitEncryption', False)
        
        print(f"Security Configuration: ✓ ({config_name})")
        print(f"  At-rest encryption: {'✓' if at_rest else '✗'}")
        print(f"  In-transit encryption: {'✓' if in_transit else '✗'}")
        
        return at_rest and in_transit
    
    def run_all_checks(self, buckets: List[str]) -> bool:
        """Run all verification checks"""
        print(f"\n=== Encryption Verification for {self.cluster_id} ===\n")
        
        ebs_ok = self.verify_ebs_encryption()
        s3_ok = self.verify_s3_encryption(buckets)
        config_ok = self.verify_security_config()
        
        all_ok = ebs_ok and s3_ok and config_ok
        
        print(f"\n{'='*50}")
        print(f"Overall Status: {'✓ PASS' if all_ok else '✗ FAIL'}")
        print(f"{'='*50}\n")
        
        return all_ok

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--cluster-id', required=True)
    parser.add_argument('--region', default='us-east-1')
    parser.add_argument('--buckets', nargs='+', required=True)
    args = parser.parse_args()
    
    verifier = EncryptionVerifier(args.cluster_id, args.region)
    success = verifier.run_all_checks(args.buckets)
    exit(0 if success else 1)
```

**Verification**: Run verification on your cluster

---

### Step 69: Create Cluster Cleanup Automation

**Objective**: Safely terminate and clean up resources.

**Actions**:
Create `scripts/cleanup/terminate_cluster.sh`:
```bash
#!/bin/bash
# Safe cluster termination with backup

set -e

CLUSTER_ID=$1
BACKUP=${2:-true}

if [ -z "$CLUSTER_ID" ]; then
    echo "Usage: $0 <cluster-id> [backup=true]"
    exit 1
fi

echo "Terminating cluster: $CLUSTER_ID"

# Backup important data if requested
if [ "$BACKUP" = "true" ]; then
    echo "Creating backup..."
    python3 ../../python/src/utils/backup_cluster_data.py --cluster-id $CLUSTER_ID
fi

# Terminate cluster
aws emr terminate-clusters --cluster-ids $CLUSTER_ID

# Wait for termination
echo "Waiting for cluster termination..."
aws emr wait cluster-terminated --cluster-id $CLUSTER_ID

echo "Cluster terminated successfully"
```

**Verification**: Test on development cluster

---

### Step 70: Implement Logging and Auditing

**Objective**: Set up comprehensive logging.

**Actions**:
```bash
# Enable CloudTrail for EMR API calls
python3 python/src/monitoring/setup_cloudtrail.py \
  --trail-name emr-encryption-audit \
  --s3-bucket emr-encryption-dev-logs-ACCOUNT_ID

# Enable VPC Flow Logs
python3 python/src/monitoring/setup_vpc_flow_logs.py \
  --vpc-id $(terraform output -raw vpc_id) \
  --log-group /aws/vpc/emr-encryption-dev
```

**Verification**:
```bash
aws cloudtrail describe-trails --trail-name-list emr-encryption-audit
aws ec2 describe-flow-logs --filter Name=resource-id,Values=$(terraform output -raw vpc_id)
```

**Expected Output**: CloudTrail and VPC Flow Logs active

---

### Step 71: Create Cost Monitoring Dashboard

**Objective**: Track and optimize AWS costs.

**Actions**:
Create `python/src/monitoring/cost_monitoring.py`:
```python
#!/usr/bin/env python3
"""
Cost Monitoring and Alerting
"""
import boto3
from datetime import datetime, timedelta

class CostMonitor:
    def __init__(self, region: str):
        self.ce = boto3.client('ce', region_name=region)
    
    def get_emr_costs(self, days: int = 30):
        """Get EMR costs for last N days"""
        end = datetime.now().date()
        start = end - timedelta(days=days)
        
        response = self.ce.get_cost_and_usage(
            TimePeriod={
                'Start': str(start),
                'End': str(end)
            },
            Granularity='DAILY',
            Filter={
                'Dimensions': {
                    'Key': 'SERVICE',
                    'Values': ['Amazon Elastic MapReduce']
                }
            },
            Metrics=['UnblendedCost']
        )
        
        total = sum(
            float(day['Total']['UnblendedCost']['Amount'])
            for day in response['ResultsByTime']
        )
        
        print(f"EMR costs (last {days} days): ${total:.2f}")
        return total

if __name__ == "__main__":
    monitor = CostMonitor('us-east-1')
    monitor.get_emr_costs(30)
```

**Verification**: Run cost monitoring script

---

### Step 72: Implement Security Best Practices

**Objective**: Harden cluster security.

**Actions**:
1. **Restrict Security Groups**:
```bash
# Update security groups for minimal access
python3 python/src/security/harden_security_groups.py \
  --cluster-id $(terraform output -raw emr_cluster_id) \
  --allowed-cidr YOUR_IP/32
```

2. **Enable MFA for Sensitive Operations**:
```bash
# Require MFA for cluster termination
python3 python/src/security/enforce_mfa.py \
  --role emr-encryption-dev-emr-service-role
```

3. **Implement Least Privilege IAM**:
Review and update IAM policies to follow least privilege principle.

**Verification**: Security audit passes

---

### Step 73: Create Disaster Recovery Plan

**Objective**: Document and test DR procedures.

**Actions**:
Create `docs/architecture/disaster-recovery.md` with:
- Backup procedures
- Recovery time objectives (RTO)
- Recovery point objectives (RPO)
- Failover procedures
- Testing schedule

**Verification**: Review with team

---

### Step 74: Performance Testing

**Objective**: Validate cluster performance under load.

**Actions**:
```bash
# Run benchmark jobs
python3 python/src/utils/run_benchmarks.py \
  --cluster-id $(terraform output -raw emr_cluster_id) \
  --test-suite terasort,spark-perf,hive-bench

# Monitor performance
python3 python/src/monitoring/performance_monitor.py \
  --cluster-id $(terraform output -raw emr_cluster_id) \
  --duration 3600
```

**Verification**: Performance meets requirements

---

### Step 75: Validate Advanced Setup

**Objective**: Confirm all advanced steps completed.

**Checklist**:
```bash
python3 scripts/validation/validate-advanced.py --environment dev
```

**Expected Output**:
```
✓ EMR cluster deployed and running
✓ Encryption at rest verified
✓ Encryption in transit verified
✓ CloudWatch monitoring active
✓ Auto-scaling configured
✓ Automation scripts functional
✓ Security hardened
✓ Logging and auditing enabled
✓ Performance validated

Advanced level complete! Ready for expert optimization.
```

---

## Advanced Level Complete! 🎉

Congratulations! You've completed the advanced level. You now have:
- ✅ Fully deployed encrypted EMR cluster
- ✅ Verified encryption at rest and in transit
- ✅ Monitoring and alerting configured
- ✅ Automation scripts for deployment
- ✅ Security best practices implemented
- ✅ Performance validated

**Next Steps**: Proceed to [Expert Level (Steps 76-100)](../expert/steps-76-100.md) for production optimization, advanced troubleshooting, and expert techniques.

---

## Quick Reference Commands

```bash
# Cluster management
aws emr describe-cluster --cluster-id <cluster-id>
aws emr list-clusters --active
aws emr terminate-clusters --cluster-ids <cluster-id>

# Verification
python3 python/src/encryption/verify_encryption.py --cluster-id <id>

# Monitoring
aws cloudwatch get-metric-statistics --namespace AWS/ElasticMapReduce

# SSH access
ssh -i ~/.ssh/emr-cluster-key.pem hadoop@<master-dns>
```
