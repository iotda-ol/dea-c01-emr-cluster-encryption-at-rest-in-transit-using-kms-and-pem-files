# Common Issues and Solutions

## Table of Contents
1. [Cluster Startup Issues](#cluster-startup-issues)
2. [Encryption Problems](#encryption-problems)
3. [Network Connectivity](#network-connectivity)
4. [Performance Issues](#performance-issues)
5. [Cost Optimization](#cost-optimization)

## Cluster Startup Issues

### Issue: Cluster stuck in STARTING state

**Symptoms**: Cluster remains in STARTING for > 30 minutes

**Possible Causes**:
- Bootstrap scripts failing
- Network configuration issues
- IAM role permissions missing
- Resource quotas exceeded

**Solutions**:
```bash
# Check bootstrap logs
aws emr describe-cluster --cluster-id <cluster-id> | jq '.Cluster.Status'

# SSH to master and check logs
ssh -i ~/.ssh/emr-cluster-key.pem hadoop@<master-dns>
sudo cat /emr/instance-controller/log/bootstrap-actions/1/stderr
```

### Issue: Cluster terminates immediately after creation

**Symptoms**: Cluster goes from STARTING to TERMINATED_WITH_ERRORS

**Common Causes**:
- Invalid security configuration
- Missing S3 bucket permissions
- Incorrect subnet configuration

**Solutions**:
```bash
# Review termination reason
aws emr describe-cluster --cluster-id <cluster-id> \
  --query 'Cluster.Status.StateChangeReason' --output text

# Check IAM role permissions
python3 python/src/utils/verify_iam_permissions.py \
  --role-name emr-encryption-dev-emr-ec2-role
```

## Encryption Problems

### Issue: EBS volumes not encrypted

**Symptoms**: `aws ec2 describe-volumes` shows Encrypted=false

**Solution**:
```bash
# Verify security configuration is applied
aws emr describe-cluster --cluster-id <cluster-id> \
  --query 'Cluster.SecurityConfiguration'

# Check KMS key permissions
python3 python/src/encryption/verify_kms_permissions.py \
  --key-id <kms-key-id>
```

### Issue: S3 access denied errors

**Symptoms**: Jobs fail with "Access Denied" when reading/writing S3

**Solution**:
```bash
# Verify KMS key policy allows EMR roles
aws kms get-key-policy --key-id <key-id> --policy-name default

# Check S3 bucket policy
aws s3api get-bucket-policy --bucket <bucket-name>

# Test S3 access from master node
ssh hadoop@<master-dns>
aws s3 ls s3://<bucket-name>/
```

### Issue: Certificate errors for in-transit encryption

**Symptoms**: "SSL handshake failed" errors

**Solution**:
```bash
# Verify certificates in S3
aws s3 ls s3://<scripts-bucket>/certificates/

# Check certificate validity
openssl x509 -in certificateChain.pem -text -noout

# Regenerate if expired
python3 python/src/certificate_manager/rotate_certificates.py \
  --bucket <scripts-bucket>
```

## Network Connectivity

### Issue: Cannot SSH to master node

**Symptoms**: Connection timeout when SSHing

**Solutions**:
```bash
# Check security group rules
aws ec2 describe-security-groups \
  --group-ids <master-security-group-id>

# Verify master node has public IP
aws emr describe-cluster --cluster-id <cluster-id> \
  --query 'Cluster.MasterPublicDnsName'

# Check VPC/subnet configuration
python3 python/src/utils/verify_network_config.py \
  --cluster-id <cluster-id>
```

### Issue: Cluster cannot access S3

**Symptoms**: Jobs fail with "Could not resolve host" for S3

**Solutions**:
```bash
# Verify NAT Gateway is working
aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=<vpc-id>"

# Check route tables
aws ec2 describe-route-tables --filters "Name=vpc-id,Values=<vpc-id>"

# Test from master node
ssh hadoop@<master-dns>
curl -v https://s3.us-east-1.amazonaws.com
```

## Performance Issues

### Issue: Jobs running very slowly

**Symptoms**: Expected 10-minute job takes hours

**Diagnosis**:
```bash
# Check cluster utilization
python3 python/src/monitoring/performance_monitor.py \
  --cluster-id <cluster-id>

# Review YARN resource allocation
ssh hadoop@<master-dns>
yarn top

# Check for data skew
# Review Spark UI at https://<master-dns>:8443/
```

**Solutions**:
- Increase number of core nodes
- Use larger instance types
- Optimize Spark configurations
- Repartition data to avoid skew

### Issue: Out of memory errors

**Symptoms**: "java.lang.OutOfMemoryError" in logs

**Solutions**:
```bash
# Increase executor memory
spark-submit \
  --executor-memory 4g \
  --driver-memory 2g \
  my-job.py

# Or update Spark defaults
# Add to config/templates/spark-defaults.conf:
# spark.executor.memory=4g
# spark.driver.memory=2g
```

## Cost Optimization

### Issue: Unexpected high costs

**Diagnosis**:
```bash
# Check running clusters
aws emr list-clusters --active

# Review costs
python3 python/src/monitoring/cost_monitoring.py --days 7

# Check for zombie clusters
aws emr list-clusters --created-after 2024-01-01 --query 'Clusters[?Status.State!=`TERMINATED`]'
```

**Solutions**:
1. Enable auto-termination for dev clusters
2. Use Spot instances for task nodes
3. Right-size instance types
4. Implement auto-scaling
5. Set up cost alerts

## Getting Help

If these solutions don't resolve your issue:

1. **Check AWS Service Health**: https://status.aws.amazon.com
2. **Review EMR Logs**: 
   ```bash
   python3 python/src/utils/collect_logs.py --cluster-id <cluster-id>
   ```
3. **Run Diagnostics**:
   ```bash
   python3 scripts/validation/run-diagnostics.sh <cluster-id>
   ```
4. **Contact Support**: Create AWS Support ticket with collected logs
