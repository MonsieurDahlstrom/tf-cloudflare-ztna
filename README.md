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

### 2. Network Segmentation with Virtual Networks

- Creates four separate virtual networks, each with the same IP range:
  - **Development Environment**: Dedicated virtual network for development workloads
  - **Staging Environment**: Dedicated virtual network for staging workloads
  - **Production Environment**: Dedicated virtual network for production workloads
  - **Reserved**: Dedicated virtual network for administrative/security purposes
- Each virtual network has its own network security and access controls
- Teams have varying levels of access to different virtual networks based on their roles
- Provides complete network isolation between environments
- Enables granular access control through WARP profiles

### 3. Team-Specific WARP Profiles

- **Flexible Team Configuration**:
  - Define teams through a variable-driven approach
  - Support for multiple identity types (email domains, email addresses)
  - Optional team creation based on configuration
  - Each team can have its own WARP profile settings

- **WARP Profile Customization**:
  - Configurable split tunneling rules per team
  - Customizable network access controls
  - Adjustable security settings and device posture checks
  - Flexible routing rules for company domains

- **Network Access Control**:
  - Granular control over which virtual networks each team can access
  - Support for environment-specific access patterns
  - Integration with Cloudflare's Zero Trust policies
  - Customizable security controls per team

## Usage

### Basic Usage (minimal configuration)

```hcl
module "cloudflare_ztna" {
  source = "./tf-cf-ztna"
  
  cloudflare_api_token = var.cloudflare_api_token
  cloudflare_account_id = var.cloudflare_account_id
  domain_name = "yourdomain.com"
  
  # Configure private network CIDR (optional, defaults to "10.100.0.0/20")
  private_network_cidr = "10.100.0.0/20"
  
  # Configure landing zones
  landing_zones = {
    development = {
      domain_name = "dev.yourdomain.com"
      environment = "development"
    }
    staging = {
      domain_name = "staging.yourdomain.com"
      environment = "staging"
    }
    production = {
      domain_name = "prod.yourdomain.com"
      environment = "production"
    }
    reserved = {
      domain_name = "admin.yourdomain.com"
      environment = "reserved"
    }
  }
  
  # Configure teams
  teams = {
    engineering = {
      name = "Engineering"
      email_domains = ["engineering.yourdomain.com"]
      landing_zone_access = ["development"]
    }
  }
}
```

### Advanced Usage (multiple teams with different network access)

```hcl
module "cloudflare_ztna" {
  source = "./tf-cf-ztna"
  
  cloudflare_api_token = var.cloudflare_api_token
  cloudflare_account_id = var.cloudflare_account_id
  domain_name = "yourdomain.com"
  
  # Configure private network CIDR (optional, defaults to "10.100.0.0/20")
  private_network_cidr = "172.16.0.0/20"  # Custom CIDR for this deployment
  
  # Configure landing zones
  landing_zones = {
    development = {
      domain_name = "dev.yourdomain.com"
      environment = "development"
      description = "Development environment network"
    }
    staging = {
      domain_name = "staging.yourdomain.com"
      environment = "staging"
      description = "Staging environment network"
    }
    production = {
      domain_name = "prod.yourdomain.com"
      environment = "production"
      description = "Production environment network"
    }
    reserved = {
      domain_name = "admin.yourdomain.com"
      environment = "reserved"
      description = "Administrative and security network"
    }
  }
  
  # Configure teams with different access patterns
  teams = {
    engineering = {
      name = "Engineering"
      email_domains   = ["engineering.yourdomain.com"]
      email_addresses = ["lead.engineer@yourdomain.com"]
      landing_zone_access = ["development"]
      split_tunneling = {
        include = ["*.yourdomain.com"]
        exclude = ["*.github.com"]
      }
    }
    
    devops = {
      name = "DevOps"
      email_addresses = ["devops@yourdomain.com", "sre@yourdomain.com"]
      landing_zone_access = ["development", "staging", "production"]
      split_tunneling = {
        include = ["*.yourdomain.com", "*.cloudflare.com"]
        exclude = ["*.github.com"]
      }
    }
    
    security = {
      name = "Security"
      email_domains = ["security.yourdomain.com"]
      landing_zone_access = ["reserved", "development", "staging", "production"]
      split_tunneling = {
        include = ["*"]
        exclude = ["*.github.com", "*.google.com"]
      }
    }
  }
}
```

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