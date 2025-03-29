locals {
  cloudflare_account_id = var.cloudflare_account_id
  domain_name           = var.domain_name

  # CIDR network splitting
  cidr_base        = local.private_network_cidr
  development_cidr = cidrsubnet(local.cidr_base, 2, 0) # First /22 subnet
  staging_cidr     = cidrsubnet(local.cidr_base, 2, 1) # Second /22 subnet
  production_cidr  = cidrsubnet(local.cidr_base, 2, 2) # Third /22 subnet
  reserved_cidr    = cidrsubnet(local.cidr_base, 2, 3) # Fourth /22 subnet

  # Network environment information
  network_environments = {
    development = {
      name        = "Development"
      cidr        = local.development_cidr
      description = "Development environment network"
    }
    staging = {
      name        = "Staging"
      cidr        = local.staging_cidr
      description = "Staging environment network"
    }
    production = {
      name        = "Production"
      cidr        = local.production_cidr
      description = "Production environment network"
    }
    reserved = {
      name        = "Reserved"
      cidr        = local.reserved_cidr
      description = "Reserved for future use"
    }
  }

  # Transform email addresses to objects with 'email' key for each team
  team_email_objects = {
    for team in var.teams : team.name => [
      for address in coalesce(team.email_addresses, []) : { email = { email = address } }
    ]
  }

  # Determine which networks each team should have access to based on their network_access setting
  team_network_access = {
    for team in var.teams : team.name => {
      networks = [
        for env_name, env in local.network_environments : env.cidr
        if contains(split(" ", lower(team.network_access)), lower(env_name))
      ]
    }
  }
}

# Create random string for uniqueness
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

#------------------------------------------------------
# Zero Trust Team Groups (User Categorization)
#------------------------------------------------------

# Create different user groups for access control
resource "cloudflare_zero_trust_access_group" "teams" {
  for_each  = { for team in var.teams : team.name => team }
  account_id = local.cloudflare_account_id
  name       = "${title(each.value.name)} Team - ${random_string.suffix.result}"

  include {
    email = local.team_email_objects[each.key]
  }
}

#------------------------------------------------------
# WARP Profiles (Device Settings based on user groups)
#------------------------------------------------------

resource "cloudflare_zero_trust_device_custom_profile" "teams" {
  for_each  = { for team in var.teams : team.name => team }
  account_id = local.cloudflare_account_id
  name       = "${title(each.value.name)} WARP Profile - ${random_string.suffix.result}"
  description = each.value.description
  precedence  = 100 + index(var.teams, each.value)

  match = "any(identity.groups.id[*] in {\"${cloudflare_zero_trust_access_group.teams[each.key].id}\"})"

  # WARP client settings
  service_mode_v2 = {
    mode = "warp"
  }
  enabled           = true
  switch_locked     = true # Don't allow users to disable WARP
  captive_portal    = 180
  allow_mode_switch = false # Don't allow switching between modes
  auto_connect      = 300   # 5 minutes

  # Include networks based on team's network_access setting
  include = [
    for network in local.team_network_access[each.key].networks : {
      address     = network
      description = "${title(each.value.name)} Resources"
    }
  ]
}

# Gateway policies to implement access controls
resource "cloudflare_zero_trust_gateway_policy" "teams" {
  for_each  = { for team in var.teams : team.name => team }
  account_id = local.cloudflare_account_id
  name       = "${title(each.value.name)} Access Policy - ${random_string.suffix.result}"
  description = each.value.description
  precedence  = 100 + index(var.teams, each.value)
  action      = "allow"
  enabled     = true
  traffic     = "net.dst.ip in {${join(" ", local.team_network_access[each.key].networks)}}"
  identity    = "any(identity.groups.id[*] in {\"${cloudflare_zero_trust_access_group.teams[each.key].id}\"})"
}

#------------------------------------------------------
# Data resources for existing Cloudflare configuration
#------------------------------------------------------

data "cloudflare_zone" "main" {
  zone_id = var.cloudflare_zone_id
} 