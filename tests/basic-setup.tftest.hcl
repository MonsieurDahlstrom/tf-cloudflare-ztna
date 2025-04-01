run "basic-setup" {
  module {
    source = "./examples/minimal"
  }

  assert {
    condition     = module.ztna.team_groups != null
    error_message = "Module ID should not be null"
  }

  assert {
    condition     = module.ztna.warp_profiles != null
    error_message = "Module ID should not be null"
  }

  assert {
    condition     = module.ztna.gateway_policies != null
    error_message = "Module ID should not be null"
  }

  assert {
    condition     = module.ztna.tunnels != null
    error_message = "Tunnels output should not be null"
  }

  assert {
    condition     = alltrue([
      for tunnel in module.ztna.tunnels : 
      tunnel.a != null && tunnel.t != null && tunnel.s != null
    ])
    error_message = "All tunnels must have a, t, and s properties set"
  }

  assert {
    condition     = alltrue([
      for tunnel in module.ztna.tunnels : 
      can(regex("^[a-f0-9]{32}$", tunnel.s))
    ])
    error_message = "All tunnel 's' properties must be valid base64sha256 hashes"
  }

  assert {
    condition     = alltrue([
      for tunnel in module.ztna.tunnels : 
      can(regex("^[a-f0-9]{32}$", tunnel.t))
    ])
    error_message = "All tunnel 't' properties must be valid Cloudflare tunnel IDs"
  }

  assert {
    condition     = module.ztna.virtual_networks != null
    error_message = "Module ID should not be null"
  }

  assert {
    condition     = module.ztna.tunnel_routes != null
    error_message = "Module ID should not be null"
  }
}

