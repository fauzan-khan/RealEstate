# Real Estate Application Terraform Configuration

This directory contains the Terraform configuration for the Real Estate Application infrastructure.

## Directory Structure

```
terraform/
├── environments/
│   └── dev/
│       └── terraform.tfvars    # Development environment variables
├── modules/                    # Will contain reusable Terraform modules
├── .gitignore                 # Git ignore file
├── main.tf                    # Main Terraform configuration
├── variables.tf               # Variable definitions
├── outputs.tf                 # Output definitions
└── README.md                  # This file
```

## Prerequisites

- Terraform >= 1.0.0
- AWS CLI configured with appropriate credentials
- Basic understanding of Terraform and AWS

## Usage

1. Initialize Terraform:
   ```bash
   terraform init
   ```

2. Select the environment:
   ```bash
   # For development environment
   terraform workspace new dev
   terraform workspace select dev
   ```

3. Plan the changes:
   ```bash
   terraform plan -var-file="environments/dev/terraform.tfvars"
   ```

4. Apply the changes:
   ```bash
   terraform apply -var-file="environments/dev/terraform.tfvars"
   ```

5. To destroy the infrastructure:
   ```bash
   terraform destroy -var-file="environments/dev/terraform.tfvars"
   ```

## State Management

As per requirements, the state is managed locally. In a production environment, it's recommended to use remote state storage (like S3) with state locking (using DynamoDB).

## Adding New Resources

When adding new resources:
1. Define variables in `variables.tf`
2. Add resource configurations in `main.tf`
3. Add any outputs in `outputs.tf`
4. Update environment-specific variables in `environments/<env>/terraform.tfvars`

## Security Notes

- Keep your terraform.tfstate file secure as it may contain sensitive information
- Don't commit sensitive values to version control
- Use AWS IAM roles with least privilege principle

## Modules

Modules will be added in the `modules/` directory as we implement specific components:
- Networking (VPC, subnets, etc.)
- Database (Aurora PostgreSQL)
- Compute (ECS/Fargate)
- Storage (S3)
- Security (IAM, Security Groups)
- Monitoring (CloudWatch)