# Frequently Asked Questions (FAQ)

## General Questions

### What is this project?
This is a comprehensive implementation guide for deploying Amazon EMR clusters with full encryption (at rest and in transit) using AWS KMS and PEM certificates. It includes a 100-step learning path from beginner to expert.

### Who is this for?
- Data engineers learning AWS EMR
- DevOps engineers deploying secure infrastructure
- Anyone preparing for AWS DEA-C01 certification
- Teams implementing secure data processing pipelines

### How long does it take to complete?
- **Quick deployment**: 30-60 minutes
- **Complete learning path**: 24-32 hours
- **Individual levels**: 4-10 hours each

## Technical Questions

### What AWS services are used?
- Amazon EMR (Elastic MapReduce)
- AWS KMS (Key Management Service)
- Amazon S3
- Amazon VPC
- AWS IAM
- Amazon CloudWatch
- AWS CloudTrail

### What are the costs?
Development environment (running 24/7):
- EMR cluster: $200-400/month
- S3 storage: $5-20/month
- KMS: $1/month
- Data transfer: $10-50/month
- **Total**: ~$220-470/month

**Cost-saving tips**:
- Enable auto-termination for dev clusters
- Use Spot instances for task nodes
- Implement lifecycle policies for S3
- Right-size instance types

### Can I use this in production?
Yes! The infrastructure is production-ready. However:
- Review and adjust security settings
- Implement proper backup/DR procedures
- Set up comprehensive monitoring
- Follow the Expert level (Steps 76-100) for production optimization
- Use separate AWS accounts for environments

### What EMR versions are supported?
The code uses EMR 6.15.0 by default, but you can use any EMR 6.x version by updating the `release_label` variable.

## Setup Questions

### What are the prerequisites?
- AWS Account with appropriate permissions
- AWS CLI installed and configured
- Python 3.8+
- Terraform 1.0+
- Git
- Basic command-line knowledge

### How do I get started quickly?
1. Run `bash scripts/setup/setup.sh`
2. Navigate to `terraform/environments/dev`
3. Run `terraform init && terraform apply`
4. Follow the [Quick Start Guide](QUICKSTART.md)

### Do I need programming experience?
Basic familiarity with:
- Command line/terminal
- Text editing
- Following step-by-step instructions

The guide teaches you as you go!

## Security Questions

### Is the encryption secure?
Yes! The implementation uses:
- AWS KMS for key management
- AES-256 encryption for data at rest
- TLS 1.2+ for data in transit
- Industry best practices

### How are certificates managed?
- Generated using cryptography library
- Self-signed (for dev/testing)
- Stored encrypted in S3
- Rotatable via automated scripts

For production, use:
- Certificates from a trusted CA
- AWS Certificate Manager
- Automated rotation policies

### What about compliance?
The architecture supports:
- HIPAA
- PCI-DSS
- SOC 2
- GDPR

However, full compliance requires additional:
- Logging and auditing
- Access controls
- Data retention policies
- Regular security assessments

## Operational Questions

### How do I monitor the cluster?
- CloudWatch dashboards (automated setup)
- CloudWatch alarms for critical metrics
- EMR console for cluster status
- Custom Python monitoring scripts

### What if something goes wrong?
1. Check [Troubleshooting Guide](troubleshooting/common-issues.md)
2. Review CloudWatch logs
3. Run diagnostic scripts in `scripts/validation/`
4. Check AWS Service Health Dashboard

### How do I scale the cluster?
**Manual scaling**:
```bash
aws emr modify-instance-groups \
  --cluster-id j-xxxxx \
  --instance-groups InstanceGroupId=ig-xxxxx,InstanceCount=5
```

**Auto-scaling**: Configured in Terraform EMR module with YARN metrics.

### How do I upgrade EMR version?
1. Update `release_label` in `terraform.tfvars`
2. Run `terraform plan` to review changes
3. Apply changes during maintenance window
4. Test thoroughly

## Learning Questions

### What's the best learning path?
**For beginners**: Follow sequentially
1. Beginner (Steps 1-25)
2. Intermediate (Steps 26-50)
3. Advanced (Steps 51-75)
4. Expert (Steps 76-100)

**For experienced users**: 
- Review Beginner for context
- Jump to Intermediate or Advanced
- Focus on specific topics as needed

### Can I skip steps?
Yes, but:
- Each level builds on previous knowledge
- Skipping may cause confusion
- Better to skim than skip entirely

### What if I get stuck?
1. Re-read the step carefully
2. Check for typos in commands
3. Review prerequisite steps
4. Consult troubleshooting guide
5. Use AWS documentation
6. Run validation scripts

## Deployment Questions

### Can I deploy to multiple regions?
Yes! Modify Terraform configuration:
```hcl
provider "aws" {
  alias  = "us-west-2"
  region = "us-west-2"
}
```

Then duplicate environments for each region.

### How do I handle multiple environments?
Use separate directories:
- `terraform/environments/dev/`
- `terraform/environments/staging/`
- `terraform/environments/prod/`

Each with its own:
- State file
- Variables
- Configuration

### Can I use this with existing infrastructure?
Yes! The modules are designed to be:
- Standalone or integrated
- Importable into existing Terraform
- Compatible with existing VPCs/subnets

Use `terraform import` for existing resources.

## Customization Questions

### Can I modify the modules?
Absolutely! The code is:
- Modular and reusable
- Well-documented
- Designed for customization

Make changes in:
- `terraform/modules/` for infrastructure
- `python/src/` for utilities
- `config/` for configurations

### Can I add more EMR applications?
Yes! Update the `applications` variable:
```hcl
applications = ["Hadoop", "Spark", "Hive", "Presto", "Flink", "HBase"]
```

### Can I use different instance types?
Yes! Modify in `terraform.tfvars`:
```hcl
master_instance_type = "r5.2xlarge"
core_instance_type   = "r5.xlarge"
```

## Troubleshooting Questions

### Cluster won't start
Common causes:
- Invalid security configuration
- Missing IAM permissions
- Insufficient subnet IPs
- Service limits exceeded

See [Troubleshooting Guide](troubleshooting/common-issues.md).

### Jobs are failing
Check:
- Logs in S3 logs bucket
- YARN resource allocation
- Spark/Hadoop configurations
- Data format/location

### High costs
Review:
- Running clusters (terminate unused)
- Instance types (right-size)
- Auto-termination settings
- S3 storage (lifecycle policies)

## Additional Resources

### Where can I learn more?
- [AWS EMR Documentation](https://docs.aws.amazon.com/emr/)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [DEA-C01 Certification Guide](https://aws.amazon.com/certification/certified-data-analytics-specialty/)

### How do I get help?
1. GitHub Issues
2. AWS Support (if you have a support plan)
3. AWS Forums
4. Stack Overflow (tag: amazon-emr)

### Can I contribute?
Yes! Contributions welcome:
- Bug fixes
- Documentation improvements
- New features
- Example implementations

---

**Still have questions?** Check the [Troubleshooting Guide](troubleshooting/common-issues.md) or create a GitHub issue.
