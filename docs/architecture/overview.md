# EMR Architecture Overview

## System Architecture

This project implements a secure Amazon EMR cluster with comprehensive encryption at rest and in transit.

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         AWS Cloud                            │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                    VPC (10.0.0.0/16)                 │   │
│  │                                                       │   │
│  │  ┌──────────────┐         ┌─────────────────────┐  │   │
│  │  │ Public Subnet│         │  Private Subnet      │  │   │
│  │  │              │         │                      │  │   │
│  │  │  NAT Gateway │────────▶│  EMR Cluster        │  │   │
│  │  │              │         │  - Master Node      │  │   │
│  │  └──────────────┘         │  - Core Nodes       │  │   │
│  │         │                 │  - Task Nodes       │  │   │
│  │         │                 └─────────────────────┘  │   │
│  │         │                          │               │   │
│  │  ┌──────▼──────┐                  │               │   │
│  │  │   Internet  │                  │               │   │
│  │  │   Gateway   │                  │               │   │
│  │  └─────────────┘                  │               │   │
│  └─────────────────────────────────────┼──────────────┘   │
│                                        │                   │
│  ┌─────────────────────────────────────▼──────────────┐   │
│  │                  S3 Buckets (Encrypted)             │   │
│  │  - Logs Bucket                                      │   │
│  │  - Data Bucket                                      │   │
│  │  - Scripts Bucket                                   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │           KMS (Key Management Service)               │  │
│  │  - Customer Master Key (CMK)                         │  │
│  │  - Automatic Key Rotation                            │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Component Details

#### 1. Networking Layer
- **VPC**: Isolated network environment
- **Public Subnet**: NAT Gateway and bastion hosts
- **Private Subnet**: EMR cluster nodes (enhanced security)
- **NAT Gateway**: Outbound internet access for private subnet
- **Internet Gateway**: Inbound/outbound for public subnet

#### 2. Compute Layer (EMR Cluster)
- **Master Node**: Cluster coordination, resource management (YARN)
- **Core Nodes**: Data storage (HDFS) and processing
- **Task Nodes**: Additional processing capacity (optional, can use Spot)

#### 3. Storage Layer
- **S3 Buckets**:
  - Logs: EMR cluster logs, application logs
  - Data: Input/output data for jobs
  - Scripts: Bootstrap scripts, configurations, certificates
- **HDFS**: Temporary storage on cluster nodes
- **EBS Volumes**: Attached to EC2 instances

#### 4. Security Layer
- **KMS**: Encryption key management
- **Security Groups**: Network access control
- **IAM Roles**: Access permissions
- **Security Configuration**: EMR encryption settings

### Data Flow

1. **Data Ingestion**: 
   - Data uploaded to S3 (encrypted with KMS)
   - Spark/Hive jobs read from encrypted S3

2. **Processing**: 
   - Data processed on EMR cluster
   - In-transit encryption via TLS
   - Temporary data on encrypted EBS volumes

3. **Output**: 
   - Results written back to S3 (encrypted)
   - Logs stored in encrypted logs bucket

### Encryption Implementation

#### Encryption at Rest
- **S3**: SSE-KMS (Server-Side Encryption with KMS)
- **EBS**: EBS encryption with KMS
- **HDFS**: Local disk encryption with KMS

#### Encryption in Transit
- **TLS/SSL**: All network communication
- **PEM Certificates**: Stored in S3, deployed during bootstrap
- **Application Level**: Spark, Hive, Hadoop RPC encryption

## Reference Architecture Compliance

This architecture follows AWS Well-Architected Framework:
- **Security**: Encryption, least privilege, defense in depth
- **Reliability**: Multi-AZ capability, automated backups
- **Performance**: Right-sized instances, auto-scaling
- **Cost**: Spot instances, lifecycle policies, auto-termination
- **Operational Excellence**: Infrastructure as Code, monitoring

## DEA-C01 Certification Alignment

This project demonstrates key skills for AWS Certified Data Analytics:
- Secure data lake architecture
- EMR cluster deployment and configuration
- Encryption implementation (at rest and in transit)
- S3 data management and lifecycle policies
- IAM roles and policies for data access
- CloudWatch monitoring and logging
