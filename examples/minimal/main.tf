terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

# Define the private network CIDR
locals {
  private_network_cidr = "10.100.0.0/20"
}

# Create virtual networks for each landing zone
resource "cloudflare_zero_trust_tunnel_cloudflared_virtual_network" "landing_zones" {
  for_each = { for lz in var.landingzones : lz.domain_name => lz }
  
  account_id = var.cloudflare_account_id
  name       = "${each.value.environment}-network"
  comment    = "Virtual network for ${each.value.environment} environment"
}

# Create cloudflared tunnels for each landing zone
resource "cloudflare_zero_trust_tunnel_cloudflared" "landing_zones" {
  for_each = { for lz in var.landingzones : lz.domain_name => lz }
  
  account_id = var.cloudflare_account_id
  name       = "${each.value.environment}-tunnel"
  tunnel_secret     = random_string.tunnel_secrets[each.key].result
}

# Generate random secrets for each tunnel
resource "random_string" "tunnel_secrets" {
  for_each = { for lz in var.landingzones : lz.domain_name => lz }
  length  = 32
  special = false
}

# Create tunnel routes for each landing zone
resource "cloudflare_zero_trust_tunnel_cloudflared_route" "landing_zones" {
  for_each = { for lz in var.landingzones : lz.domain_name => lz }
  
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.landing_zones[each.key].id
  network    = local.private_network_cidr
  virtual_network_id = cloudflare_zero_trust_tunnel_cloudflared_virtual_network.landing_zones[each.key].id
}

module "zero_trust" {
  source = "../../"

  cloudflare_api_token = var.cloudflare_api_token
  cloudflare_account_id = var.cloudflare_account_id
  cloudflare_zone_id    = var.cloudflare_zone_id

  landingzones = var.landingzones

  teams = [
    {
      name        = "engineering"
      description = "Engineering team with access to development environment"
      email_addresses = ["engineer@example.com"]
      environments = ["development"]
      allowed_domains = ["dev.example.com", "tools.example.com", "git.example.com"]
    },
    {
      name        = "devops"
      description = "DevOps team with access to all environments"
      email_addresses = ["devops@example.com"]
      environments = ["development", "staging", "production"]
      allowed_domains = ["*.example.com"]
    },
    {
      name        = "security"
      description = "Security team with access to all environments"
      email_addresses = ["security@example.com"]
      environments = ["development", "staging", "production"]
      allowed_domains = ["*.example.com"]
    }
  ]
}

# Output the virtual network IDs for reference
output "virtual_networks" {
  description = "Map of environment names to virtual network IDs"
  value = {
    for lz in var.landingzones : lz.environment => cloudflare_zero_trust_tunnel_cloudflared_virtual_network.landing_zones[lz.domain_name].id
  }
}

# Output the tunnel IDs for reference
output "tunnels" {
  description = "Map of environment names to tunnel IDs"
  value = {
    for lz in var.landingzones : lz.environment => cloudflare_zero_trust_tunnel_cloudflared.landing_zones[lz.domain_name].id
  }
}

# Output the tunnel routes for reference
output "tunnel_routes" {
  description = "Map of environment names to tunnel route configurations"
  value = {
    for lz in var.landingzones : lz.environment => {
      network = local.private_network_cidr
      tunnel_id = cloudflare_zero_trust_tunnel_cloudflared.landing_zones[lz.domain_name].id
      virtual_network_id = cloudflare_zero_trust_tunnel_cloudflared_virtual_network.landing_zones[lz.domain_name].id
    }
  }
} 