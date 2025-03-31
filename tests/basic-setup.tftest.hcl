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
    error_message = "Module ID should not be null"
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

