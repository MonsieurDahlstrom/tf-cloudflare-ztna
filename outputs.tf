# This shows how user groups and WARP profiles combine for Zero Trust access
output "zero_trust_warp_profiles" {
  description = "WARP profiles configured for different user groups"
  value = {
    # Deployment identifier
    deployment_id = random_string.suffix.result

    # User groups with their membership information
    user_groups = {
      for team in var.teams : team.name => {
        name      = cloudflare_zero_trust_access_group.teams[team.name].name
        id        = cloudflare_zero_trust_access_group.teams[team.name].id
        member_of = title(team.name) + " Team"
      }
    }

    # WARP profiles for each team
    warp_profiles = {
      for team in var.teams : team.name => {
        name            = cloudflare_zero_trust_device_custom_profile.teams[team.name].name
        description     = cloudflare_zero_trust_device_custom_profile.teams[team.name].description
        split_tunnel    = "Configured to route access based on team requirements"
        allowed_domains = team.allowed_domains
        network_access  = team.network_access
      }
    }

    # Gateway policies for access control
    gateway_policies = {
      for team in var.teams : team.name => {
        name         = cloudflare_zero_trust_gateway_policy.teams[team.name].name
        description  = cloudflare_zero_trust_gateway_policy.teams[team.name].description
        action       = cloudflare_zero_trust_gateway_policy.teams[team.name].action
        filters      = cloudflare_zero_trust_gateway_policy.teams[team.name].filters
        block_page   = cloudflare_zero_trust_gateway_policy.teams[team.name].rule_settings.block_page_enabled
        override_ips = cloudflare_zero_trust_gateway_policy.teams[team.name].rule_settings.override_ips
      }
    }

    # Network environments created from the /20 CIDR
    network_environments = {
      base_cidr = local.private_network_cidr
      subnets = {
        development = {
          cidr          = local.development_cidr
          description   = local.network_environments.development.description
          accessible_by = "Engineering team, DevOps team"
        }
        staging = {
          cidr          = local.staging_cidr
          description   = local.network_environments.staging.description
          accessible_by = "DevOps team"
        }
        production = {
          cidr          = local.production_cidr
          description   = local.network_environments.production.description
          accessible_by = "DevOps team"
        }
        reserved = {
          cidr          = local.reserved_cidr
          description   = local.network_environments.reserved.description
          accessible_by = "Security team"
        }
      }
    }

    # Documentation of the approach
    security_model = "Zero Trust control through: 1) User identity verification via groups, 2) Device validation with WARP custom profiles, 3) Traffic routing through gateway rules with environment-specific network segmentation"
  }
}

output "private_network_cidr" {
  description = "The private network CIDR block (/20) used for network segmentation"
  value       = local.private_network_cidr
}
