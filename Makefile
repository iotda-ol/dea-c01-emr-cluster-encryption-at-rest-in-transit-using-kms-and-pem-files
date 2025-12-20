.PHONY: help init plan apply destroy validate format clean install-python install-terraform generate-certs upload-certs check

# Variables
CERT_DIR ?= ./certificates
BUCKET_NAME ?= $(shell terraform output -raw certificates_bucket_name 2>/dev/null || echo "")
AWS_REGION ?= us-east-1
TERRAFORM_VERSION ?= 1.6.6

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install-python: ## Install Python dependencies
	@echo "Installing Python dependencies..."
	pip install -r requirements.txt

install-terraform: ## Install Terraform (Linux only)
	@echo "Installing Terraform $(TERRAFORM_VERSION)..."
	@cd /tmp && \
	wget -q https://releases.hashicorp.com/terraform/$(TERRAFORM_VERSION)/terraform_$(TERRAFORM_VERSION)_linux_amd64.zip && \
	unzip -q terraform_$(TERRAFORM_VERSION)_linux_amd64.zip && \
	sudo mv terraform /usr/local/bin/ && \
	terraform version

generate-certs: ## Generate PEM certificates
	@echo "Generating certificates..."
	python scripts/generate_certificates.py --output-dir $(CERT_DIR)

upload-certs: ## Upload certificates to S3
	@if [ -z "$(BUCKET_NAME)" ]; then \
		echo "Error: Cannot determine bucket name. Run 'terraform apply' first."; \
		exit 1; \
	fi
	@echo "Uploading certificates to S3..."
	python scripts/upload_certificates.py \
		--bucket-name $(BUCKET_NAME) \
		--bundle-path $(CERT_DIR)/certificateBundle.zip \
		--aws-region $(AWS_REGION)

init: ## Initialize Terraform
	@echo "Initializing Terraform..."
	terraform init

validate: ## Validate Terraform configuration
	@echo "Validating Terraform configuration..."
	terraform validate

format: ## Format Terraform files
	@echo "Formatting Terraform files..."
	terraform fmt -recursive

plan: validate ## Run Terraform plan
	@echo "Running Terraform plan..."
	terraform plan

apply: validate ## Apply Terraform configuration
	@echo "Applying Terraform configuration..."
	terraform apply

destroy: ## Destroy Terraform resources
	@echo "Destroying Terraform resources..."
	terraform destroy

check: validate ## Run all validation checks
	@echo "Running validation checks..."
	@echo "✓ Terraform validation passed"
	@terraform fmt -check -recursive && echo "✓ Terraform formatting check passed" || (echo "✗ Terraform formatting check failed. Run 'make format' to fix." && exit 1)
	@python -m py_compile scripts/*.py && echo "✓ Python syntax check passed" || (echo "✗ Python syntax check failed" && exit 1)
	@echo "All checks passed!"

clean: ## Clean temporary files
	@echo "Cleaning temporary files..."
	rm -rf .terraform/
	rm -rf $(CERT_DIR)/
	rm -f .terraform.lock.hcl
	rm -f terraform.tfstate*
	rm -f crash.log

output: ## Show Terraform outputs
	@terraform output

status: ## Show EMR cluster status
	@if [ -z "$(shell terraform output -raw emr_cluster_id 2>/dev/null)" ]; then \
		echo "No cluster deployed yet"; \
	else \
		echo "Cluster ID: $$(terraform output -raw emr_cluster_id)"; \
		aws emr describe-cluster --cluster-id $$(terraform output -raw emr_cluster_id) --query 'Cluster.Status.State' --output text; \
	fi

logs: ## View EMR logs location
	@echo "EMR Logs S3 URI: s3://$$(terraform output -raw logs_bucket_name)/emr-logs/"

all: install-python init generate-certs plan ## Run full setup (except apply)
	@echo "Setup complete. Review the plan and run 'make apply' to deploy."

deploy: all apply upload-certs ## Full deployment pipeline
	@echo "Deployment complete!"
	@make output
