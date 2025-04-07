# Cloudflare Zero Trust Network Access Module

This Terraform module implements Cloudflare Zero Trust Network Access (ZTNA) with team-based access controls and environment-specific landing zones.

The module creates virtual networks, cloudflared tunnels, and WARP profiles for different teams with customized access rules.

## Module Structure

The module is organized into several key components:

- `providers.tf` - Cloudflare provider configuration
- `variables.tf` - Input variable definitions
- `main.tf` - Core resources and implementation
- `outputs.tf` - Output definitions
- `versions.tf` - Provider and module version constraints

## Features

### 1. Landing Zone Management

- Creates environment-specific landing zones (development, staging, production)
- Each landing zone has its own:
  - Virtual network
  - Cloudflared tunnel
  - Tunnel routes
- Configurable domain names for each environment
- Automatic secret generation for tunnels

### 2. Team-Based Access Control

- Creates Zero Trust access groups for different teams
- Supports multiple identity types:
  - Email addresses
  - Email domains
  - GitHub identities (optional)
- Teams can be assigned to specific environments
- Granular access control through gateway policies

### 3. WARP Profile Configuration

- Team-specific WARP profiles with:
  - Automatic connection settings
  - Locked switch mode
  - Configurable captive portal behavior
  - Automatic updates enabled
  - WireGuard tunnel protocol
- Precedence-based profile ordering
- Environment-specific network access

## Usage

### Basic Usage

```hcl
module "cloudflare_ztna" {
  source = "./tf-cloudflare-ztna"
  
  cloudflare_api_token = var.cloudflare_api_token
  cloudflare_account_id = var.cloudflare_account_id
  cloudflare_zone_id    = var.cloudflare_zone_id
  
  # Optional suffix for resource names
  suffix = "prod"
  
  # Configure private network CIDR (must be a /22 CIDR in a private range)
  private_network_cidr = "10.0.0.0/22"
  
  # Configure landing zones
  landingzones = [
    {
      domain_name = "dev.example.com"
      environment = "development"
    },
    {
      domain_name = "staging.example.com"
      environment = "staging"
    },
    {
      domain_name = "prod.example.com"
      environment = "production"
    }
  ]
  
  # Configure teams
  teams = [
    {
      name            = "engineering"
      description     = "Engineering team with development access"
      email_domains   = ["engineering.example.com"]
      environments    = ["development"]
      allowed_domains = ["*.example.com"]
    },
    {
      name            = "devops"
      description     = "DevOps team with full access"
      email_addresses = ["devops@example.com"]
      environments    = ["development", "staging", "production"]
      allowed_domains = ["*.example.com", "*.cloudflare.com"]
    }
  ]
}
```

## Input Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| suffix | Optional suffix to append to all resource names | string | "" | no |
| cloudflare_api_token | Cloudflare API token | string | n/a | yes |
| cloudflare_account_id | Cloudflare account ID | string | n/a | yes |
| cloudflare_zone_id | Cloudflare zone ID | string | "" | no |
| private_network_cidr | CIDR block for private networks (/22) | string | "10.0.0.0/22" | no |
| landingzones | List of landing zone configurations | list(object) | [] | no |
| teams | List of team configurations | list(object) | [] | no |

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

- `checkov` for security and compliance scanning
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