#!/usr/bin/env python3
"""
Validate prerequisites for EMR encryption project
"""
import subprocess
import sys
import os
from typing import Tuple

def check_command(command: str, min_version: str = None) -> Tuple[bool, str]:
    """Check if a command is available and optionally verify version"""
    try:
        result = subprocess.run(
            [command, "--version"],
            capture_output=True,
            text=True,
            timeout=5
        )
        if result.returncode == 0:
            version_output = result.stdout + result.stderr
            return True, version_output.split('\n')[0]
        return False, "Command failed"
    except (subprocess.TimeoutExpired, FileNotFoundError):
        return False, "Not found"

def check_aws_credentials() -> Tuple[bool, str]:
    """Check if AWS credentials are configured"""
    try:
        result = subprocess.run(
            ["aws", "sts", "get-caller-identity"],
            capture_output=True,
            text=True,
            timeout=10
        )
        if result.returncode == 0:
            return True, "AWS credentials configured"
        return False, "AWS credentials not configured"
    except Exception as e:
        return False, f"Error: {e}"

def check_python_packages() -> Tuple[bool, str]:
    """Check if required Python packages are installed"""
    required_packages = ['boto3', 'cryptography']
    try:
        import importlib
        for package in required_packages:
            importlib.import_module(package)
        return True, f"All required packages installed"
    except ImportError as e:
        return False, f"Missing package: {e.name}"

def check_ssh_key() -> Tuple[bool, str]:
    """Check if SSH key exists"""
    key_path = os.path.expanduser("~/.ssh/emr-cluster-key.pem")
    if os.path.exists(key_path):
        return True, f"SSH key found at {key_path}"
    return False, "SSH key not found"

def main():
    """Run all prerequisite checks"""
    print("=" * 60)
    print("EMR Encryption - Prerequisites Validation")
    print("=" * 60)
    print()

    checks = [
        ("AWS CLI", lambda: check_command("aws")),
        ("Python 3", lambda: check_command("python3")),
        ("Terraform", lambda: check_command("terraform")),
        ("Git", lambda: check_command("git")),
        ("AWS Credentials", check_aws_credentials),
        ("Python Packages", check_python_packages),
        ("SSH Key", check_ssh_key),
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
        print("✓ All beginner prerequisites met! Ready for intermediate level.")
        print("=" * 60)
        return 0
    else:
        print("✗ Some prerequisites are missing. Please install required tools.")
        print("=" * 60)
        return 1

if __name__ == "__main__":
    sys.exit(main())
