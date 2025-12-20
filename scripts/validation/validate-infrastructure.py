#!/usr/bin/env python3
"""
Validate EMR infrastructure deployment
"""
import argparse
import boto3
import sys
from typing import Tuple, List


class InfrastructureValidator:
    def __init__(self, environment: str, region: str = 'us-east-1'):
        self.environment = environment
        self.region = region
        self.project_name = 'emr-encryption'
        
        # AWS clients
        self.kms = boto3.client('kms', region_name=region)
        self.ec2 = boto3.client('ec2', region_name=region)
        self.s3 = boto3.client('s3', region_name=region)
        self.iam = boto3.client('iam', region_name=region)
        self.emr = boto3.client('emr', region_name=region)
        self.sts = boto3.client('sts', region_name=region)
        
        self.account_id = self.sts.get_caller_identity()['Account']
    
    def check_kms_key(self) -> Tuple[bool, str]:
        """Check if KMS key exists and is configured correctly"""
        try:
            alias_name = f"alias/{self.project_name}-{self.environment}-emr-encryption"
            response = self.kms.describe_key(KeyId=alias_name)
            
            key_id = response['KeyMetadata']['KeyId']
            key_state = response['KeyMetadata']['KeyState']
            rotation = self.kms.get_key_rotation_status(KeyId=key_id)
            
            if key_state == 'Enabled' and rotation.get('KeyRotationEnabled', False):
                return True, f"KMS key {key_id} (rotation enabled)"
            return False, f"KMS key {key_id} (rotation: {rotation.get('KeyRotationEnabled')})"
        except Exception as e:
            return False, f"Error: {str(e)}"
    
    def check_vpc(self) -> Tuple[bool, str]:
        """Check if VPC and networking are configured"""
        try:
            vpcs = self.ec2.describe_vpcs(
                Filters=[
                    {'Name': 'tag:Project', 'Values': [self.project_name]},
                    {'Name': 'tag:Environment', 'Values': [self.environment]}
                ]
            )['Vpcs']
            
            if not vpcs:
                return False, "VPC not found"
            
            vpc_id = vpcs[0]['VpcId']
            
            # Check subnets
            subnets = self.ec2.describe_subnets(
                Filters=[{'Name': 'vpc-id', 'Values': [vpc_id]}]
            )['Subnets']
            
            if len(subnets) >= 2:
                return True, f"VPC {vpc_id} with {len(subnets)} subnets"
            return False, f"VPC {vpc_id} but only {len(subnets)} subnet(s)"
        except Exception as e:
            return False, f"Error: {str(e)}"
    
    def check_s3_buckets(self) -> Tuple[bool, str]:
        """Check if S3 buckets exist with encryption"""
        bucket_types = ['logs', 'data', 'scripts']
        found_buckets = []
        encrypted_buckets = []
        
        for bucket_type in bucket_types:
            bucket_name = f"{self.project_name}-{self.environment}-{bucket_type}-{self.account_id}"
            try:
                # Check if bucket exists
                self.s3.head_bucket(Bucket=bucket_name)
                found_buckets.append(bucket_type)
                
                # Check encryption
                encryption = self.s3.get_bucket_encryption(Bucket=bucket_name)
                if encryption:
                    encrypted_buckets.append(bucket_type)
            except:
                pass
        
        if len(found_buckets) == 3 and len(encrypted_buckets) == 3:
            return True, f"All 3 buckets exist with encryption"
        return False, f"Found {len(found_buckets)}/3 buckets, {len(encrypted_buckets)} encrypted"
    
    def check_iam_roles(self) -> Tuple[bool, str]:
        """Check if IAM roles are configured"""
        required_roles = [
            f"{self.project_name}-{self.environment}-emr-service-role",
            f"{self.project_name}-{self.environment}-emr-ec2-role"
        ]
        
        found_roles = []
        for role_name in required_roles:
            try:
                self.iam.get_role(RoleName=role_name)
                found_roles.append(role_name)
            except:
                pass
        
        if len(found_roles) == 2:
            return True, f"All IAM roles configured"
        return False, f"Found {len(found_roles)}/2 required roles"
    
    def check_security_config(self) -> Tuple[bool, str]:
        """Check if EMR security configuration exists"""
        try:
            config_name = f"{self.project_name}-{self.environment}-security-config"
            self.emr.describe_security_configuration(Name=config_name)
            return True, f"Security configuration: {config_name}"
        except:
            return False, "Security configuration not found"
    
    def check_certificates(self) -> Tuple[bool, str]:
        """Check if certificates are uploaded to S3"""
        try:
            bucket_name = f"{self.project_name}-{self.environment}-scripts-{self.account_id}"
            response = self.s3.list_objects_v2(
                Bucket=bucket_name,
                Prefix='certificates/'
            )
            
            if 'Contents' in response:
                cert_files = [obj['Key'] for obj in response['Contents']]
                required_files = ['privateKey.pem', 'certificateChain.pem', 'trustedCertificates.pem']
                
                if all(f"certificates/{f}" in cert_files for f in required_files):
                    return True, f"All certificates uploaded"
                return False, f"Missing certificate files"
            return False, "Certificates directory not found"
        except Exception as e:
            return False, f"Error: {str(e)}"
    
    def run_all_checks(self) -> bool:
        """Run all validation checks"""
        print("=" * 60)
        print(f"Infrastructure Validation - {self.environment.upper()} Environment")
        print("=" * 60)
        print()
        
        checks = [
            ("KMS Key", self.check_kms_key),
            ("VPC & Networking", self.check_vpc),
            ("S3 Buckets", self.check_s3_buckets),
            ("IAM Roles", self.check_iam_roles),
            ("Security Configuration", self.check_security_config),
            ("Certificates", self.check_certificates),
        ]
        
        results = []
        for name, check_func in checks:
            passed, message = check_func()
            status = "✓" if passed else "✗"
            print(f"{status} {name}: {message}")
            results.append(passed)
        
        print()
        print("=" * 60)
        
        if all(results):
            print("✓ All infrastructure validation checks passed!")
            print("=" * 60)
            return True
        else:
            failed_count = len([r for r in results if not r])
            print(f"✗ {failed_count} check(s) failed. Please review and fix.")
            print("=" * 60)
            return False


def main():
    parser = argparse.ArgumentParser(
        description="Validate EMR infrastructure deployment"
    )
    parser.add_argument(
        "--environment",
        default="dev",
        choices=["dev", "staging", "prod"],
        help="Environment to validate"
    )
    parser.add_argument(
        "--region",
        default="us-east-1",
        help="AWS region"
    )
    args = parser.parse_args()
    
    validator = InfrastructureValidator(args.environment, args.region)
    success = validator.run_all_checks()
    
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
