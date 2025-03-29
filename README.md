# Cloudflare Zero Trust WARP Profiles Module

This Terraform module demonstrates how to implement user group-based WARP profiles using Cloudflare's Zero Trust products. The module creates different WARP profiles for different user groups, with customized split tunneling and security settings for each group, including network segmentation with CIDR blocks.

## Module Structure

The module is structured using standard Terraform practices:

- `providers.tf` - Contains provider configuration
- `variables.tf` - Defines input variables
- `main.tf` - Core resources and implementation
- `outputs.tf` - Outputs that describe the WARP profiles

## WARP Profile Implementation Approach

This module implements a multi-layer approach to WARP profile configuration:

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

## Implementation Features

The module demonstrates:

1. **Zero Trust User Groups with Variable-Driven Configuration**
   - Creates logical groupings of users based on roles
   - Configurable via variables for easy user management
   - **Optional team creation** (only creates teams that are explicitly configured)
   - Supports multiple identity types (email, domain, GitHub, etc.)

2. **Network Segmentation with CIDR Subnets**
   - Splits a single /20 CIDR into four /22 environment subnets
   - Configurable base CIDR via variable input
   - Clear network boundaries between environments
   - Detailed output showing CIDR allocations

3. **Team-Specific WARP Profiles with Environment Access**
   - Creates targeted WARP configurations for different teams
   - Customizes split tunneling based on team needs
   - Controls which environments each team can access:
     - Engineering: Development only
     - DevOps: All environments (development, staging, production)
     - Security: Reserved network plus all traffic

4. **Unique Resource Naming**
   - Uses the random provider to generate a unique suffix
   - Appends the suffix to all resource names
   - Makes resources easily identifiable by deployment
   - Prevents conflicts when creating multiple deployments

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

## Key Benefits

1. **User-Centric Security** - Security follows the user, not the network
2. **Group-Based Profile Assignment** - Automated WARP profile assignment based on group membership
3. **Traffic Segmentation** - Different WARP profiles route different traffic through WARP
4. **Environment Isolation** - Clear network boundaries between development, staging, and production
5. **Team-Appropriate Access** - Each team only gets access to the environments they need
6. **Easy Maintenance** - Variable-driven configuration for team membership and network allocation
7. **Flexible Deployment** - Create only the teams and profiles you need
8. **Resource Name Uniqueness** - Random suffix prevents naming conflicts between deployments

## Resources

- [Cloudflare Zero Trust Documentation](https://developers.cloudflare.com/cloudflare-one/)
- [Cloudflare WARP Documentation](https://developers.cloudflare.com/cloudflare-one/connections/connect-devices/warp/)
- [Cloudflare Gateway Documentation](https://developers.cloudflare.com/cloudflare-one/policies/filtering/) 