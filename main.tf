locals {
  cloudflare_account_id = var.cloudflare_account_id

  # Create a suffix for resource names
  name_suffix = var.suffix != "" ? "-${var.suffix}" : ""

  # Create a list of conditions for each team
  team_match_conditions = {
    for team in var.teams : team.name => [
      # User groups condition
      length(coalesce(team.user_groups, [])) > 0 ?
      "any(identity.groups.id[*] in {${join(", ", [for group in team.user_groups : "\"${group}\""])}})" :
      null,
      # Email addresses condition
      length(coalesce(team.email_addresses, [])) > 0 ?
      "identity.email in {${join(" ", [for email in team.email_addresses : "\"${email}\""])}}" :
      null
    ]
  }

  # Map of environment to landing zone domain
  environment_domain_map = {
    for lz in var.landingzones : lz.environment => lz.domain_name...
  }

  # Create a list of team-environment combinations for gateway policies
  team_environment_policies = flatten([
    for team in var.teams : [
      for env in team.environments : {
        id        = "${team.name}-${env}"
        team_name = team.name
        team      = team
        env       = env
        vnet_id = cloudflare_zero_trust_tunnel_cloudflared_virtual_network.landing_zones[
          lookup(local.environment_domain_map, env, [])[0]
        ].id
      }
      if contains([for lz in var.landingzones : lz.environment], env)
    ]
  ])
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

# Generate random secrets for each tunnel
resource "random_string" "tunnel_secrets" {
  for_each = { for lz in var.landingzones : lz.domain_name => lz }
  length   = 32
  special  = false
  upper    = false
}

# Create virtual networks for each landing zone
resource "cloudflare_zero_trust_tunnel_cloudflared_virtual_network" "landing_zones" {
  for_each = { for lz in var.landingzones : lz.domain_name => lz }

  account_id = local.cloudflare_account_id
  name       = "${each.value.environment}-network${local.name_suffix}"
  comment    = "Virtual network for ${each.value.environment} environment"
  is_default = false
}

# Create cloudflared tunnels for each landing zone
resource "cloudflare_zero_trust_tunnel_cloudflared" "landing_zones" {
  for_each = { for lz in var.landingzones : lz.domain_name => lz }

  account_id    = local.cloudflare_account_id
  name          = "${each.value.environment}-tunnel${local.name_suffix}"
  config_src    = "local"
  tunnel_secret = base64sha256(random_string.tunnel_secrets[each.key].result)
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
# WARP Profiles (Device Settings based on user groups)
#------------------------------------------------------

resource "cloudflare_zero_trust_device_custom_profile" "teams" {
  for_each = { for idx, team in var.teams : team.name => {
    name        = team.name
    description = team.description
    precedence  = var.base_precedence + idx
  } }
  account_id  = local.cloudflare_account_id
  name        = trimspace("${title(each.value.name)} WARP Settings ${local.name_suffix}")
  description = each.value.description
  precedence  = each.value.precedence
  match       = join(" or ", [for condition in local.team_match_conditions[each.key] : condition if condition != null])

  # WARP client settings
  enabled = true
  #default               = false
  switch_locked         = true # Don't allow users to disable WARP
  captive_portal        = 5
  allow_mode_switch     = false # Don't allow switching between modes
  auto_connect          = 0     # 5 minutes 
  allow_updates         = true
  allowed_to_leave      = true
  disable_auto_fallback = false
  exclude_office_ips    = false
  tunnel_protocol       = "masque"
  support_url           = ""
  include = [{
    address     = var.private_network_cidr
    description = "Include the Cloudflare Private network"
  }]
}

# Gateway policies to implement access controls
resource "cloudflare_zero_trust_gateway_policy" "teams" {
  for_each = { for idx, policy in local.team_environment_policies : policy.id => policy }

  account_id  = local.cloudflare_account_id
  name        = trimspace("${title(each.value.team_name)} ${title(each.value.env)} Access Policy ${local.name_suffix}")
  description = each.value.team.description
  precedence  = var.base_precedence + 100 + index(local.team_environment_policies.*.id, each.key)
  action      = "allow"
  enabled     = true
  traffic     = "net.dst.ip in {${var.private_network_cidr}} and net.vnet_id == \"${each.value.vnet_id}\""
  identity    = join(" or ", [for condition in local.team_match_conditions[each.value.team_name] : condition if condition != null])
}

# Default deny rule to block all traffic that doesn't match any of the team rules
resource "cloudflare_zero_trust_gateway_policy" "default_deny" {
  account_id  = local.cloudflare_account_id
  name        = trimspace("Default Deny Policy ${local.name_suffix}")
  description = "Default deny policy to block all traffic that doesn't match any of the team rules"
  precedence  = var.base_precedence + 100 + length(local.team_environment_policies) + 1 # Higher precedence than all team rules
  action      = "block"
  enabled     = true
  traffic     = "net.dst.ip in {${var.private_network_cidr}}" # Only block traffic to the private network in any virtual network
  identity    = ""                                            # Match all identities
}