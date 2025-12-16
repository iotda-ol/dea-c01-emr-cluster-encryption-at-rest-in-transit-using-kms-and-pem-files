# Security Best Practices for EMR Cluster

## Overview

This document outlines the security best practices implemented in this EMR cluster configuration, aligned with AWS DEA-C01 (Data Engineer Associate) certification requirements for data encryption and security.

## DEA-C01 Encryption Best Practices

### 1. Encryption at Rest

#### S3 Data Encryption
- **Implementation**: Server-Side Encryption with AWS KMS (SSE-KMS)
- **Key Management**: Customer-managed KMS key with automatic rotation enabled
- **Scope**: All data stored in S3 buckets (certificates, logs, and application data)

**Best Practices Applied:**
- ✓ Use AWS KMS for centralized key management
- ✓ Enable automatic key rotation annually
- ✓ Implement least-privilege KMS key policies
- ✓ Enforce encryption through S3 bucket policies
- ✓ Enable S3 bucket versioning for audit trail

#### Local Disk Encryption
- **Implementation**: EBS volume encryption using AWS KMS
- **Scope**: All EMR cluster node volumes (master and core nodes)

**Best Practices Applied:**
- ✓ Encrypt all EBS volumes with KMS
- ✓ Use the same KMS key for consistency
- ✓ Enable encryption by default at cluster creation

### 2. Encryption in Transit

#### TLS/SSL Encryption
- **Implementation**: PEM certificate-based encryption for inter-node communication
- **Certificate Storage**: Encrypted S3 bucket with restricted access
- **Applications**: All EMR applications (Spark, Hadoop, Hive)

**Best Practices Applied:**
- ✓ Enable HTTPS for all web interfaces
- ✓ Use TLS 1.2 or higher for data transmission
- ✓ Encrypt Spark shuffle data
- ✓ Enable SSL for Hadoop RPC communication
- ✓ Secure certificate storage in encrypted S3

#### Network Security
- **VPC Isolation**: EMR cluster deployed in private subnet
- **Security Groups**: Least-privilege network access rules
- **IMDSv2**: Enforce Instance Metadata Service version 2

**Best Practices Applied:**
- ✓ Restrict network access to required ports only
- ✓ Use security groups with minimal ingress rules
- ✓ Enable VPC Flow Logs for network monitoring
- ✓ Disable public IP addresses where possible
- ✓ Use IMDSv2 to prevent SSRF attacks

### 3. Identity and Access Management (IAM)

#### Service Roles
1. **EMR Service Role**: Manages EMR cluster lifecycle
2. **EMR EC2 Role**: Used by EC2 instances in the cluster
3. **EMR Autoscaling Role**: Manages cluster autoscaling

**Least Privilege Principles:**
- ✓ Separate roles for different functions
- ✓ Grant only necessary permissions
- ✓ Use AWS managed policies as baseline
- ✓ Add custom policies for specific resources
- ✓ Restrict S3 access to specific buckets
- ✓ Limit KMS permissions to required operations

#### Resource-Based Policies
- **S3 Bucket Policies**: Enforce SSL/TLS for all connections
- **KMS Key Policy**: Allow access only to EMR service and EC2 roles
- **Condition Keys**: Use ViaService conditions for additional security

### 4. Logging and Monitoring

#### CloudWatch Logs
- EMR application logs
- System logs
- Step execution logs

#### S3 Logging
- Cluster logs stored in encrypted S3 bucket
- Lifecycle policies for log retention (90 days default)
- Versioning enabled for audit compliance

**Best Practices Applied:**
- ✓ Enable comprehensive logging
- ✓ Encrypt all logs at rest
- ✓ Set appropriate log retention periods
- ✓ Use lifecycle policies for cost optimization
- ✓ Enable CloudTrail for API audit logging

### 5. Certificate Management

#### Generation
- Use strong cryptographic algorithms (RSA 2048+)
- Generate self-signed certificates for internal communication
- Set appropriate validity periods (1 year default)

#### Storage
- Store certificates in encrypted S3 bucket
- Use versioning for certificate rotation
- Restrict access via IAM and bucket policies

#### Rotation
- Plan for certificate rotation before expiration
- Test rotation process in non-production environment
- Update EMR security configuration after rotation

**Best Practices Applied:**
- ✓ Use industry-standard key sizes (2048-bit RSA minimum)
- ✓ Store certificates securely in encrypted S3
- ✓ Implement certificate lifecycle management
- ✓ Restrict access to certificates
- ✓ Monitor certificate expiration dates

## Security Configuration Summary

### Encryption at Rest
| Component | Encryption Method | Key Management |
|-----------|-------------------|----------------|
| S3 Data | SSE-KMS | Customer-managed KMS key |
| EBS Volumes | KMS | Customer-managed KMS key |
| S3 Logs | SSE-KMS | Customer-managed KMS key |

### Encryption in Transit
| Component | Encryption Method | Certificate Type |
|-----------|-------------------|------------------|
| Inter-node | TLS 1.2+ | Self-signed PEM |
| Spark | SSL + Network Encryption | PEM certificates |
| Hadoop RPC | SSL | PEM certificates |
| Web Interfaces | HTTPS | PEM certificates |

### Network Security
| Control | Implementation | Purpose |
|---------|----------------|---------|
| VPC | Private subnet deployment | Network isolation |
| Security Groups | Least-privilege rules | Access control |
| IMDSv2 | Enforced | Prevent metadata abuse |
| SSL/TLS | Required for all S3 operations | Secure data transfer |

## Compliance and Audit

### DEA-C01 Alignment
This implementation addresses key DEA-C01 exam topics:
- ✓ Data encryption at rest using KMS
- ✓ Data encryption in transit using TLS/SSL
- ✓ Secure data storage in S3
- ✓ IAM least privilege access control
- ✓ Monitoring and logging for compliance
- ✓ Key rotation and certificate management

### Audit Capabilities
- **CloudTrail**: All API calls logged and auditable
- **S3 Access Logs**: Track all S3 object access
- **VPC Flow Logs**: Network traffic analysis
- **CloudWatch**: Real-time monitoring and alerting
- **KMS Audit**: Track all key usage

## Security Checklist

Before deploying to production:

- [ ] Review and customize KMS key policies
- [ ] Validate IAM role permissions
- [ ] Test certificate generation and upload
- [ ] Configure VPC and subnet settings
- [ ] Set up CloudWatch alarms
- [ ] Enable CloudTrail logging
- [ ] Configure S3 access logging
- [ ] Test SSH/HTTPS access restrictions
- [ ] Verify encryption settings
- [ ] Document certificate rotation process
- [ ] Set up automated backup procedures
- [ ] Review security group rules
- [ ] Test disaster recovery procedures
- [ ] Configure monitoring dashboards

## Incident Response

In case of security incidents:

1. **Immediate Actions**
   - Terminate compromised cluster if necessary
   - Rotate affected credentials and certificates
   - Review CloudTrail logs for suspicious activity

2. **Investigation**
   - Analyze VPC Flow Logs
   - Review S3 access logs
   - Check KMS key usage logs
   - Examine EMR cluster logs

3. **Remediation**
   - Apply security patches
   - Update security group rules
   - Rotate KMS keys if compromised
   - Update IAM policies

4. **Prevention**
   - Implement additional monitoring
   - Update security configurations
   - Enhance access controls
   - Conduct security training

## Additional Resources

- [AWS EMR Security](https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-security.html)
- [AWS KMS Best Practices](https://docs.aws.amazon.com/kms/latest/developerguide/best-practices.html)
- [DEA-C01 Exam Guide](https://aws.amazon.com/certification/certified-data-engineer-associate/)
- [AWS Security Best Practices](https://aws.amazon.com/architecture/security-identity-compliance/)

## Contact

For security concerns or questions, please contact your security team or AWS support.
