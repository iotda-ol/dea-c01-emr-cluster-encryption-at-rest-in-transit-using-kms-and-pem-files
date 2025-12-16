#!/usr/bin/env python3
"""
Generate self-signed PEM certificates for EMR in-transit encryption.

This script generates:
- Private key (privateKey.pem)
- Certificate signing request
- Self-signed certificate (certificateChain.pem)
- Certificate bundle in ZIP format for EMR

Usage:
    python generate_certificates.py --output-dir /path/to/output
"""

import argparse
import os
import sys
import zipfile
from datetime import datetime, timedelta, timezone
from pathlib import Path

try:
    from cryptography import x509
    from cryptography.hazmat.backends import default_backend
    from cryptography.hazmat.primitives import hashes, serialization
    from cryptography.hazmat.primitives.asymmetric import rsa
    from cryptography.x509.oid import NameOID
except ImportError:
    print("Error: cryptography package is required. Install it with: pip install cryptography")
    sys.exit(1)


def generate_private_key(key_size=2048):
    """Generate RSA private key."""
    print(f"Generating {key_size}-bit RSA private key...")
    private_key = rsa.generate_private_key(
        public_exponent=65537,
        key_size=key_size,
        backend=default_backend()
    )
    return private_key


def generate_self_signed_certificate(private_key, common_name="*.compute.internal", 
                                     organization="EMR Cluster", validity_days=365):
    """Generate self-signed certificate."""
    print(f"Generating self-signed certificate for {common_name}...")
    
    # Generate certificate subject
    subject = issuer = x509.Name([
        x509.NameAttribute(NameOID.COUNTRY_NAME, "US"),
        x509.NameAttribute(NameOID.STATE_OR_PROVINCE_NAME, "Washington"),
        x509.NameAttribute(NameOID.LOCALITY_NAME, "Seattle"),
        x509.NameAttribute(NameOID.ORGANIZATION_NAME, organization),
        x509.NameAttribute(NameOID.COMMON_NAME, common_name),
    ])
    
    # Build certificate
    now = datetime.now(timezone.utc)
    cert = (
        x509.CertificateBuilder()
        .subject_name(subject)
        .issuer_name(issuer)
        .public_key(private_key.public_key())
        .serial_number(x509.random_serial_number())
        .not_valid_before(now)
        .not_valid_after(now + timedelta(days=validity_days))
        .add_extension(
            x509.SubjectAlternativeName([
                x509.DNSName(common_name),
                x509.DNSName("*.ec2.internal"),
                x509.DNSName("localhost"),
            ]),
            critical=False,
        )
        .add_extension(
            # Set ca=False for EMR node certificates (not used as CA)
            x509.BasicConstraints(ca=False, path_length=None),
            critical=True,
        )
        .sign(private_key, hashes.SHA256(), default_backend())
    )
    
    return cert


def save_private_key(private_key, output_path):
    """Save private key to PEM file."""
    print(f"Saving private key to {output_path}...")
    pem = private_key.private_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PrivateFormat.TraditionalOpenSSL,
        encryption_algorithm=serialization.NoEncryption()
    )
    
    with open(output_path, 'wb') as f:
        f.write(pem)
    
    # Set restrictive permissions
    os.chmod(output_path, 0o600)


def save_certificate(certificate, output_path):
    """Save certificate to PEM file."""
    print(f"Saving certificate to {output_path}...")
    pem = certificate.public_bytes(serialization.Encoding.PEM)
    
    with open(output_path, 'wb') as f:
        f.write(pem)


def create_certificate_bundle(output_dir):
    """Create ZIP bundle containing certificates for EMR."""
    bundle_path = output_dir / "certificateBundle.zip"
    print(f"Creating certificate bundle at {bundle_path}...")
    
    files_to_bundle = [
        "privateKey.pem",
        "certificateChain.pem"
    ]
    
    with zipfile.ZipFile(bundle_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for filename in files_to_bundle:
            file_path = output_dir / filename
            if file_path.exists():
                zipf.write(file_path, filename)
                print(f"  Added {filename} to bundle")
    
    print(f"Certificate bundle created successfully: {bundle_path}")
    return bundle_path


def main():
    parser = argparse.ArgumentParser(
        description="Generate self-signed PEM certificates for EMR in-transit encryption"
    )
    parser.add_argument(
        "--output-dir",
        type=str,
        default="./certificates",
        help="Directory to save generated certificates (default: ./certificates)"
    )
    parser.add_argument(
        "--common-name",
        type=str,
        default="*.compute.internal",
        help="Common name for certificate (default: *.compute.internal)"
    )
    parser.add_argument(
        "--organization",
        type=str,
        default="EMR Cluster",
        help="Organization name for certificate (default: EMR Cluster)"
    )
    parser.add_argument(
        "--validity-days",
        type=int,
        default=365,
        help="Certificate validity in days (default: 365)"
    )
    parser.add_argument(
        "--key-size",
        type=int,
        default=2048,
        choices=[2048, 4096],
        help="RSA key size in bits (default: 2048)"
    )
    
    args = parser.parse_args()
    
    # Create output directory
    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)
    print(f"Output directory: {output_dir.absolute()}")
    
    # Generate private key
    private_key = generate_private_key(key_size=args.key_size)
    
    # Generate self-signed certificate
    certificate = generate_self_signed_certificate(
        private_key,
        common_name=args.common_name,
        organization=args.organization,
        validity_days=args.validity_days
    )
    
    # Save private key
    private_key_path = output_dir / "privateKey.pem"
    save_private_key(private_key, private_key_path)
    
    # Save certificate
    cert_path = output_dir / "certificateChain.pem"
    save_certificate(certificate, cert_path)
    
    # Create certificate bundle
    bundle_path = create_certificate_bundle(output_dir)
    
    print("\n" + "=" * 70)
    print("Certificate generation completed successfully!")
    print("=" * 70)
    print(f"\nGenerated files:")
    print(f"  - Private Key: {private_key_path}")
    print(f"  - Certificate: {cert_path}")
    print(f"  - Bundle:      {bundle_path}")
    print(f"\nNext steps:")
    print(f"  1. Review the generated certificates")
    print(f"  2. Upload the bundle to S3 using upload_certificates.py")
    print(f"  3. Update your EMR security configuration to reference the S3 location")
    print("\nSecurity Note:")
    print("  - Keep privateKey.pem secure and do not commit to version control")
    print("  - Use appropriate IAM policies to restrict S3 bucket access")
    print("  - Rotate certificates regularly (before expiration)")
    
    return 0


if __name__ == "__main__":
    sys.exit(main())
