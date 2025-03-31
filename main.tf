locals {
  cloudflare_account_id = var.cloudflare_account_id

  # Transform email addresses to objects with 'email' key for each team
  team_email_objects = {
    for team in var.teams : team.name => [
      for address in coalesce(team.email_addresses, []) : { email = { email = address } }
    ]
  }

  # Determine which networks each team should have access to based on their environments setting
  team_network_access = {
    for team in var.teams : team.name => {
      networks = [
        for lz in var.landingzones : var.private_network_cidr
        if contains(coalesce(team.environments, ["development"]), lz.environment)
      ]
    }
  }

  # Create a suffix for resource names
  name_suffix = var.suffix != "" ? "-${var.suffix}" : ""
}

# Create random string for uniqueness
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

#------------------------------------------------------
# Virtual Networks and Tunnels
#------------------------------------------------------

# Create virtual networks for each landing zone
resource "cloudflare_zero_trust_tunnel_cloudflared_virtual_network" "landing_zones" {
  for_each = { for lz in var.landingzones : lz.domain_name => lz }

  account_id         = local.cloudflare_account_id
  name               = "${each.value.environment}-network${local.name_suffix}"
  comment            = "Virtual network for ${each.value.environment} environment"
  is_default = false
}

# Create cloudflared tunnels for each landing zone
resource "cloudflare_zero_trust_tunnel_cloudflared" "landing_zones" {
  for_each = { for lz in var.landingzones : lz.domain_name => lz }

  account_id    = local.cloudflare_account_id
  name          = "${each.value.environment}-tunnel${local.name_suffix}"
  tunnel_secret = random_string.tunnel_secrets[each.key].result
}

# Generate random secrets for each tunnel
resource "random_string" "tunnel_secrets" {
  for_each = { for lz in var.landingzones : lz.domain_name => lz }
  length   = 32
  special  = false
}

# Create tunnel routes for each landing zone
resource "cloudflare_zero_trust_tunnel_cloudflared_route" "landing_zones" {
  for_each = { for lz in var.landingzones : lz.domain_name => lz }

  account_id         = local.cloudflare_account_id
  tunnel_id          = cloudflare_zero_trust_tunnel_cloudflared.landing_zones[each.key].id
  network            = var.private_network_cidr
  virtual_network_id = cloudflare_zero_trust_tunnel_cloudflared_virtual_network.landing_zones[each.key].id
}

#------------------------------------------------------
# Zero Trust Team Groups (User Categorization)
#------------------------------------------------------

# Create different user groups for access control
resource "cloudflare_zero_trust_access_group" "teams" {
  for_each   = { for team in var.teams : team.name => team }
  account_id = local.cloudflare_account_id
  name       = "${title(each.value.name)} Team${local.name_suffix}"

  include = local.team_email_objects[each.key]
}

#------------------------------------------------------
# WARP Profiles (Device Settings based on user groups)
#------------------------------------------------------

resource "cloudflare_zero_trust_device_custom_profile" "teams" {
  for_each    = { for team in var.teams : team.name => team }
  account_id  = local.cloudflare_account_id
  name        = "${title(each.value.name)} WARP Profile${local.name_suffix}"
  description = each.value.description
  precedence  = 100 + index(var.teams, each.value)

  match = "any(identity.groups.id[*] in {\"${cloudflare_zero_trust_access_group.teams[each.key].id}\"})"

  # WARP client settings
  service_mode_v2 = {
    mode = "warp"
  }
  enabled                        = true
  switch_locked                  = true # Don't allow users to disable WARP
  captive_portal                 = 180
  allow_mode_switch              = false # Don't allow switching between modes
  auto_connect                   = 300   # 5 minutes
  allow_updates                  = true
  allowed_to_leave               = true
  disable_auto_fallback          = false
  exclude_office_ips             = false
  register_interface_ip_with_dns = true
  tunnel_protocol                = "wireguard"
  support_url                    = ""
  # Include networks based on team's environments setting
  include = [
    for network in local.team_network_access[each.key].networks : {
      address     = network
      description = "${title(each.value.name)} Resources"
    }
  ]
}

# Gateway policies to implement access controls
resource "cloudflare_zero_trust_gateway_policy" "teams" {
  for_each    = { for team in var.teams : team.name => team }
  account_id  = local.cloudflare_account_id
  name        = "${title(each.value.name)} Access Policy${local.name_suffix}"
  description = each.value.description
  precedence  = var.base_precedence + index(var.teams, each.value)
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