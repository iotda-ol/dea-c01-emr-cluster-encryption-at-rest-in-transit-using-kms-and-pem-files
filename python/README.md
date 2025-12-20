# Python Utilities

Python packages and utilities for EMR cluster management, deployment, and monitoring.

## Packages

### certificate_manager
Certificate generation and management for in-transit encryption.

**Features**:
- Generate self-signed certificates
- Certificate rotation
- Upload to S3
- Validation

**Example**:
```python
from certificate_manager import CertificateManager

manager = CertificateManager(s3_bucket="my-bucket", s3_prefix="certs/")
private_key, cert = manager.generate_certificate()
manager.upload_to_s3(private_key, cert)
```

### deployment
Automated EMR cluster deployment and configuration.

**Features**:
- Cluster deployment
- Configuration management
- Bootstrap automation
- Blue-green deployment

**Example**:
```python
from deployment import EMRDeployer

deployer = EMRDeployer(region='us-east-1', environment='dev')
cluster_id = deployer.deploy_cluster(config)
deployer.wait_for_cluster(cluster_id)
```

### encryption
Encryption verification and validation utilities.

**Features**:
- Verify encryption at rest
- Verify encryption in transit
- KMS key validation
- S3 encryption checks

**Example**:
```python
from encryption import EncryptionVerifier

verifier = EncryptionVerifier(cluster_id='j-123456', region='us-east-1')
results = verifier.run_all_checks(buckets=['bucket1', 'bucket2'])
```

### monitoring
Monitoring, metrics, and alerting.

**Features**:
- CloudWatch integration
- Custom metrics
- Dashboard creation
- Alarm configuration
- Cost monitoring

**Example**:
```python
from monitoring import AdvancedMonitor

monitor = AdvancedMonitor(cluster_id='j-123456', region='us-east-1')
monitor.monitor_job_execution()
monitor.publish_custom_metric('MyMetric', 100, 'Count')
```

### utils
General utility functions and helpers.

**Features**:
- Configuration management
- Logging utilities
- Data quality checks
- Helper functions

## Installation

```bash
# Create virtual environment
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
```

## Usage

```python
# Import from installed package
from src.encryption import EncryptionVerifier
from src.monitoring import AdvancedMonitor
from src.deployment import EMRDeployer
```

## Testing

```bash
# Run all tests
pytest tests/

# Run specific test file
pytest tests/unit/test_encryption.py

# Run with coverage
pytest --cov=src tests/
```

## Development

```bash
# Install dev dependencies
pip install -r requirements-dev.txt

# Format code
black src/

# Lint code
pylint src/
flake8 src/

# Type checking
mypy src/
```

## Project Structure

```
python/
├── src/                    # Source code
│   ├── certificate_manager/
│   ├── deployment/
│   ├── encryption/
│   ├── monitoring/
│   └── utils/
├── tests/                  # Tests
│   ├── unit/
│   └── integration/
└── requirements.txt        # Dependencies
```

## Best Practices

1. **Type Hints**: Use type hints for better code clarity
2. **Documentation**: Docstrings for all public functions
3. **Error Handling**: Comprehensive error handling
4. **Logging**: Structured logging throughout
5. **Testing**: Unit tests for all critical functions
