#!/usr/bin/env python3
"""
Upload PEM certificate bundle to S3 for EMR in-transit encryption.

This script uploads the certificate bundle to the S3 bucket specified
in your Terraform configuration.

Usage:
    python upload_certificates.py --bucket-name my-bucket --bundle-path ./certificates/certificateBundle.zip
"""

import argparse
import os
import sys
from pathlib import Path

try:
    import boto3
    from botocore.exceptions import ClientError, NoCredentialsError
except ImportError:
    print("Error: boto3 package is required. Install it with: pip install boto3")
    sys.exit(1)


def upload_to_s3(bucket_name, local_file_path, s3_key, kms_key_id=None):
    """
    Upload a file to S3 bucket.
    
    Args:
        bucket_name: Name of the S3 bucket
        local_file_path: Local path to the file to upload
        s3_key: S3 key (path) where the file will be stored
        kms_key_id: Optional KMS key ID for encryption (uses bucket default if not provided)
    
    Returns:
        True if upload was successful, False otherwise
    """
    s3_client = boto3.client('s3')
    
    try:
        print(f"Uploading {local_file_path} to s3://{bucket_name}/{s3_key}...")
        
        # Upload with server-side encryption
        extra_args = {
            'ServerSideEncryption': 'aws:kms',
            'StorageClass': 'STANDARD'
        }
        
        # Add KMS key ID if provided
        if kms_key_id:
            extra_args['SSEKMSKeyId'] = kms_key_id
        
        s3_client.upload_file(
            local_file_path,
            bucket_name,
            s3_key,
            ExtraArgs=extra_args
        )
        
        print(f"✓ Upload successful!")
        print(f"  S3 URI: s3://{bucket_name}/{s3_key}")
        
        return True
        
    except FileNotFoundError:
        print(f"Error: Local file not found: {local_file_path}")
        return False
    except NoCredentialsError:
        print("Error: AWS credentials not found. Configure AWS credentials first.")
        return False
    except ClientError as e:
        print(f"Error: Failed to upload to S3: {e}")
        return False


def verify_bucket_exists(bucket_name):
    """
    Verify that the S3 bucket exists and is accessible.
    
    Args:
        bucket_name: Name of the S3 bucket
    
    Returns:
        True if bucket exists and is accessible, False otherwise
    """
    s3_client = boto3.client('s3')
    
    try:
        s3_client.head_bucket(Bucket=bucket_name)
        print(f"✓ Bucket '{bucket_name}' exists and is accessible")
        return True
    except ClientError as e:
        error_code = e.response['Error']['Code']
        if error_code == '404':
            print(f"Error: Bucket '{bucket_name}' does not exist")
        elif error_code == '403':
            print(f"Error: Access denied to bucket '{bucket_name}'")
        else:
            print(f"Error: Failed to access bucket '{bucket_name}': {e}")
        return False


def get_bucket_encryption(bucket_name):
    """
    Get encryption configuration of the S3 bucket.
    
    Args:
        bucket_name: Name of the S3 bucket
    """
    s3_client = boto3.client('s3')
    
    try:
        response = s3_client.get_bucket_encryption(Bucket=bucket_name)
        rules = response.get('ServerSideEncryptionConfiguration', {}).get('Rules', [])
        
        if rules:
            for rule in rules:
                sse = rule.get('ApplyServerSideEncryptionByDefault', {})
                algorithm = sse.get('SSEAlgorithm', 'None')
                kms_key = sse.get('KMSMasterKeyID', 'Default')
                print(f"✓ Bucket encryption: {algorithm}")
                if algorithm == 'aws:kms':
                    print(f"  KMS Key: {kms_key}")
        else:
            print("⚠ Warning: Bucket does not have default encryption enabled")
            
    except ClientError as e:
        if e.response['Error']['Code'] == 'ServerSideEncryptionConfigurationNotFoundError':
            print("⚠ Warning: Bucket does not have default encryption enabled")
        else:
            print(f"Warning: Could not retrieve bucket encryption: {e}")


def main():
    parser = argparse.ArgumentParser(
        description="Upload PEM certificate bundle to S3 for EMR in-transit encryption"
    )
    parser.add_argument(
        "--bucket-name",
        type=str,
        required=True,
        help="Name of the S3 bucket (e.g., my-project-dev-certificates-123456789012)"
    )
    parser.add_argument(
        "--bundle-path",
        type=str,
        default="./certificates/certificateBundle.zip",
        help="Path to the certificate bundle ZIP file (default: ./certificates/certificateBundle.zip)"
    )
    parser.add_argument(
        "--s3-prefix",
        type=str,
        default="certificates",
        help="S3 prefix (folder) for the certificate bundle (default: certificates)"
    )
    parser.add_argument(
        "--aws-region",
        type=str,
        default=None,
        help="AWS region (optional, uses default AWS configuration if not specified)"
    )
    parser.add_argument(
        "--kms-key-id",
        type=str,
        default=None,
        help="KMS key ID or ARN for encryption (optional, uses bucket default if not specified)"
    )
    
    args = parser.parse_args()
    
    # Configure boto3 session with region if specified
    if args.aws_region:
        boto3.setup_default_session(region_name=args.aws_region)
        print(f"Using AWS region: {args.aws_region}")
    
    # Verify bundle file exists
    bundle_path = Path(args.bundle_path)
    if not bundle_path.exists():
        print(f"Error: Certificate bundle not found at {bundle_path}")
        print("\nPlease generate certificates first using generate_certificates.py")
        return 1
    
    print(f"Certificate bundle: {bundle_path.absolute()}")
    print(f"Bundle size: {bundle_path.stat().st_size / 1024:.2f} KB")
    
    # Verify bucket exists
    if not verify_bucket_exists(args.bucket_name):
        return 1
    
    # Check bucket encryption
    get_bucket_encryption(args.bucket_name)
    
    # Construct S3 key
    s3_key = f"{args.s3_prefix}/certificateBundle.zip"
    
    # Upload to S3
    if args.kms_key_id:
        print(f"Using KMS key: {args.kms_key_id}")
    success = upload_to_s3(args.bucket_name, str(bundle_path), s3_key, args.kms_key_id)
    
    if success:
        print("\n" + "=" * 70)
        print("Upload completed successfully!")
        print("=" * 70)
        print(f"\nS3 Location: s3://{args.bucket_name}/{s3_key}")
        print(f"\nNext steps:")
        print(f"  1. Verify the EMR security configuration references this S3 location")
        print(f"  2. Deploy your EMR cluster with Terraform")
        print(f"  3. Monitor EMR cluster logs for any certificate-related issues")
        print("\nSecurity Reminders:")
        print("  - Ensure S3 bucket has appropriate access policies")
        print("  - Enable S3 bucket versioning for certificate rotation")
        print("  - Set up CloudTrail logging for S3 access auditing")
        print("  - Rotate certificates before expiration")
        return 0
    else:
        return 1


if __name__ == "__main__":
    sys.exit(main())
