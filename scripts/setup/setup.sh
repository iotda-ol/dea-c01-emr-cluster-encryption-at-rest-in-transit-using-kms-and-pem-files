#!/bin/bash
# Setup script for EMR encryption project

set -e

echo "=================================================="
echo "EMR Encryption Project - Setup Script"
echo "=================================================="
echo

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if running in correct directory
if [ ! -f "README.md" ]; then
    echo -e "${RED}Error: Please run this script from the project root directory${NC}"
    exit 1
fi

echo "Step 1: Checking prerequisites..."
python3 scripts/setup/validate-prerequisites.py
if [ $? -ne 0 ]; then
    echo -e "${RED}Prerequisites check failed. Please install required tools.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Prerequisites validated${NC}"
echo

echo "Step 2: Setting up Python virtual environment..."
if [ ! -d "python/venv" ]; then
    cd python
    python3 -m venv venv
    source venv/bin/activate
    pip install --upgrade pip
    pip install -r requirements.txt
    cd ..
    echo -e "${GREEN}✓ Python environment created${NC}"
else
    echo "Python virtual environment already exists"
    echo -e "${GREEN}✓ Skipping${NC}"
fi
echo

echo "Step 3: Creating configuration directories..."
mkdir -p config/certificates
mkdir -p config/templates
echo -e "${GREEN}✓ Directories created${NC}"
echo

echo "Step 4: Checking AWS credentials..."
aws sts get-caller-identity > /dev/null 2>&1
if [ $? -eq 0 ]; then
    ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    echo -e "${GREEN}✓ AWS credentials configured for account: $ACCOUNT_ID${NC}"
else
    echo -e "${RED}✗ AWS credentials not configured${NC}"
    echo "Please run: aws configure"
    exit 1
fi
echo

echo "=================================================="
echo "Setup Complete!"
echo "=================================================="
echo
echo "Next steps:"
echo "1. Activate Python environment: source python/venv/bin/activate"
echo "2. Review beginner instructions: docs/instructions/beginner/steps-01-25.md"
echo "3. Start with Terraform: cd terraform/environments/dev"
echo
