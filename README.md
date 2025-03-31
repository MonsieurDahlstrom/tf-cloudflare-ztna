# Cloudflare Zero Trust WARP Profiles Module

This Terraform module implements user group-based WARP profiles using Cloudflare's Zero Trust products. The module creates different WARP profiles for different user groups, with customized split tunneling and security settings for each group, including network segmentation with CIDR blocks.

## Module Structure

The module is organized into several key components:

- `providers.tf` - Cloudflare provider configuration
- `variables.tf` - Input variable definitions
- `main.tf` - Core resources and implementation
- `outputs.tf` - Output definitions for WARP profiles
- `locals.tf` - Local variable definitions
- `versions.tf` - Provider and module version constraints

## Features

### 1. User & Team Identity Management

- Creates distinct user groups based on organizational roles
- Categorizes users (Engineering, DevOps, Security) for access decisions
- Establishes the foundation for WARP profile assignment
- **Variable-driven group membership** for easy configuration
- **Fully optional teams** that are only created when configured

### 2. Network Segmentation with CIDR Blocks

- Takes a /20 private network CIDR and splits it into four /22 subnets:
  - **Development Environment**: First /22 subnet
  - **Staging Environment**: Second /22 subnet
  - **Production Environment**: Third /22 subnet
  - **Reserved**: Fourth /22 subnet (for administrative/security purposes)
- Provides clear network boundaries between environments
- Allows for targeted access controls based on environment

### 3. Team-Specific WARP Profiles with Environment Access

- **Engineering WARP Profile**:
  - Restricted split tunneling that only routes specific engineering resources through WARP
  - Access limited to development environment network only
  - Device posture checks for security validation
  
- **DevOps WARP Profile**:
  - Broader split tunneling configuration
  - Access to all environment networks (development, staging, production)
  - Routes all company domains through WARP
  
- **Security WARP Profile**:
  - Full tunneling with most traffic through WARP
  - Explicit access to reserved network
  - Enhanced security controls
  - Only common public services excluded from WARP

### 4. Unique Resource Naming with Random Suffix

- All resources include a random 6-character suffix in their names
- Prevents naming conflicts when deploying multiple instances
- Enables easier cleanup and avoids resource name collisions
- Each deployment has a unique identifier available in outputs

## Usage

### Basic Usage (minimal configuration)

```hcl
module "cloudflare_ztna" {
  source = "./tf-cf-ztna"
  
  cloudflare_api_token = var.cloudflare_api_token
  cloudflare_account_id = var.cloudflare_account_id
  domain_name = "yourdomain.com"
  
  # Define private network CIDR to be split
  private_network_cidr = "10.100.0.0/20"
  
  # Only create engineering team with its WARP profile
  engineering_team = {
    email_domains = ["engineering.yourdomain.com"]
  }
}

# The deployment will have a unique identifier
output "deployment_id" {
  value = module.cloudflare_ztna.zero_trust_warp_profiles.deployment_id
}
```

### Advanced Usage (multiple teams with different network access)

```hcl
module "cloudflare_ztna" {
  source = "./tf-cf-ztna"
  
  cloudflare_api_token = var.cloudflare_api_token
  cloudflare_account_id = var.cloudflare_account_id
  domain_name = "yourdomain.com"
  
  # Define private network CIDR to be split
  private_network_cidr = "172.16.0.0/20"  # Will be split into four /22 networks
  
  # Configure multiple teams with different WARP profiles and network access
  engineering_team = {
    email_domains   = ["engineering.yourdomain.com"]
    email_addresses = ["lead.engineer@yourdomain.com"]
  }
  
  devops_team = {
    email_addresses = ["devops@yourdomain.com", "sre@yourdomain.com"]
  }
  
  security_team = {
    email_domains = ["security.yourdomain.com"]
  }
}
```

## CIDR Allocation and Team Access

The module creates the following CIDR allocations and access patterns:

| Environment | CIDR (from base /20) | Accessible By |
|-------------|---------------------|---------------|
| Development | First /22 subnet    | Engineering, DevOps |
| Staging     | Second /22 subnet   | DevOps only |  
| Production  | Third /22 subnet    | DevOps only |
| Reserved    | Fourth /22 subnet   | Security only |

## Development

### Prerequisites

- Terraform >= 1.0.0
- Cloudflare API Token with appropriate permissions
- Cloudflare Zero Trust subscription

### Testing

The module includes a comprehensive test suite:

```bash
# Initialize Terraform
terraform init

# Run tests
terraform test
```

### Code Quality

This module uses several tools to maintain code quality:

- `tflint` for Terraform linting
- `pre-commit` hooks for automated checks
- GitHub Actions for CI/CD

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This Terraform module is licensed under the [Creative Commons Attribution-NonCommercial 4.0 International License (CC BY-NC 4.0)](https://creativecommons.org/licenses/by-nc/4.0/).

You are free to share, adapt, and use the code for non-commercial purposes, with attribution.

**Commercial use is prohibited** without a separate license. If you would like to use this module commercially (e.g., in client projects, paid SaaS, or commercial infrastructure), please contact the author to obtain a commercial license.

License details: https://creativecommons.org/licenses/by-nc/4.0/legalcode 