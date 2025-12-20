#!/usr/bin/env python3
"""
Generate self-signed certificates for EMR in-transit encryption
"""
import argparse
import os
from datetime import datetime, timedelta
from cryptography import x509
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.x509.oid import NameOID


def generate_private_key():
    """Generate RSA private key"""
    return rsa.generate_private_key(
        public_exponent=65537,
        key_size=2048,
        backend=default_backend()
    )


def generate_certificate(private_key, days_valid=365):
    """Generate self-signed certificate"""
    subject = issuer = x509.Name([
        x509.NameAttribute(NameOID.COUNTRY_NAME, "US"),
        x509.NameAttribute(NameOID.STATE_OR_PROVINCE_NAME, "California"),
        x509.NameAttribute(NameOID.LOCALITY_NAME, "San Francisco"),
        x509.NameAttribute(NameOID.ORGANIZATION_NAME, "EMR Encryption"),
        x509.NameAttribute(NameOID.COMMON_NAME, "emr.internal"),
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
    ).add_extension(
        x509.SubjectAlternativeName([
            x509.DNSName("*.emr.internal"),
            x509.DNSName("localhost"),
        ]),
        critical=False,
    ).sign(private_key, hashes.SHA256(), backend=default_backend())
    
    return cert


def save_certificates(private_key, cert, output_dir):
    """Save certificates to files"""
    os.makedirs(output_dir, exist_ok=True)
    
    # Save private key
    private_key_path = os.path.join(output_dir, "privateKey.pem")
    with open(private_key_path, "wb") as f:
        f.write(private_key.private_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PrivateFormat.PKCS8,
            encryption_algorithm=serialization.NoEncryption()
        ))
    
    # Save certificate
    cert_path = os.path.join(output_dir, "certificateChain.pem")
    with open(cert_path, "wb") as f:
        f.write(cert.public_bytes(serialization.Encoding.PEM))
    
    # Save trusted certificates (same as cert for self-signed)
    trusted_path = os.path.join(output_dir, "trustedCertificates.pem")
    with open(trusted_path, "wb") as f:
        f.write(cert.public_bytes(serialization.Encoding.PEM))
    
    print(f"✓ Certificates generated in {output_dir}:")
    print(f"  - {private_key_path}")
    print(f"  - {cert_path}")
    print(f"  - {trusted_path}")
    
    return private_key_path, cert_path, trusted_path


def main():
    parser = argparse.ArgumentParser(
        description="Generate self-signed certificates for EMR encryption"
    )
    parser.add_argument(
        "--output",
        default="../../config/certificates",
        help="Output directory for certificates"
    )
    parser.add_argument(
        "--days",
        type=int,
        default=365,
        help="Number of days the certificate is valid"
    )
    args = parser.parse_args()
    
    print("Generating certificates for EMR in-transit encryption...")
    
    # Generate private key
    print("1. Generating private key...")
    private_key = generate_private_key()
    
    # Generate certificate
    print("2. Generating certificate...")
    cert = generate_certificate(private_key, args.days)
    
    # Save to files
    print("3. Saving certificates...")
    save_certificates(private_key, cert, args.output)
    
    print("\n✓ Certificate generation complete!")
    print(f"  Valid for {args.days} days")
    print("\nNext steps:")
    print(f"  1. Review certificates in {args.output}")
    print("  2. Upload to S3: aws s3 cp {output}/ s3://your-bucket/certificates/ --recursive")


if __name__ == "__main__":
    main()
