# This shows how user groups and WARP profiles combine for Zero Trust access
# output "team_groups" {
#   description = "Created team access groups"
#   value = {
#     for team in var.teams : team.name => {
#       id           = cloudflare_zero_trust_access_group.teams[team.name].id
#       name         = cloudflare_zero_trust_access_group.teams[team.name].name
#       description  = team.description
#       environments = coalesce(team.environments, ["development"])
#     }
#   }
# }

output "warp_profiles" {
  description = "Created WARP device profiles"
  value = {
    for team in var.teams : team.name => {
      id          = cloudflare_zero_trust_device_custom_profile.teams[team.name].id
      name        = cloudflare_zero_trust_device_custom_profile.teams[team.name].name
      description = team.description
      precedence  = cloudflare_zero_trust_device_custom_profile.teams[team.name].precedence
      match       = cloudflare_zero_trust_device_custom_profile.teams[team.name].match
    }
  }
}

output "tunnels" {
  description = "Created Cloudflare tunnels"
  value = {
    for lz in var.landingzones : lz.environment => {
      a = local.cloudflare_account_id
      t = cloudflare_zero_trust_tunnel_cloudflared.landing_zones[lz.domain_name].id
      s = base64sha256(random_string.tunnel_secrets[lz.domain_name].result)
    }
  }
}

output "virtual_networks" {
  description = "Created virtual networks"
  value = {
    for lz in var.landingzones : lz.domain_name => {
      id      = cloudflare_zero_trust_tunnel_cloudflared_virtual_network.landing_zones[lz.domain_name].id
      name    = cloudflare_zero_trust_tunnel_cloudflared_virtual_network.landing_zones[lz.domain_name].name
      comment = cloudflare_zero_trust_tunnel_cloudflared_virtual_network.landing_zones[lz.domain_name].comment
    }
  }
}

output "tunnel_routes" {
  description = "Created tunnel routes"
  value = {
    for lz in var.landingzones : lz.domain_name => {
      id                 = cloudflare_zero_trust_tunnel_cloudflared_route.landing_zones[lz.domain_name].id
      tunnel_id          = cloudflare_zero_trust_tunnel_cloudflared_route.landing_zones[lz.domain_name].tunnel_id
      virtual_network_id = cloudflare_zero_trust_tunnel_cloudflared_route.landing_zones[lz.domain_name].virtual_network_id
      network            = cloudflare_zero_trust_tunnel_cloudflared_route.landing_zones[lz.domain_name].network
    }
  }
}

output "gateway_policies" {
  description = "Created gateway policies for team access"
  value = {
    for policy in local.team_environment_policies : policy.id => {
      id          = cloudflare_zero_trust_gateway_policy.teams[policy.id].id
      name        = cloudflare_zero_trust_gateway_policy.teams[policy.id].name
      description = cloudflare_zero_trust_gateway_policy.teams[policy.id].description
      precedence  = cloudflare_zero_trust_gateway_policy.teams[policy.id].precedence
      team        = policy.team_name
      environment = policy.env
    }
  }
}

output "default_deny_policy" {
  description = "Default deny policy details"
  value = {
    id          = cloudflare_zero_trust_gateway_policy.default_deny.id
    name        = cloudflare_zero_trust_gateway_policy.default_deny.name
    description = cloudflare_zero_trust_gateway_policy.default_deny.description
    precedence  = cloudflare_zero_trust_gateway_policy.default_deny.precedence
  }
}
