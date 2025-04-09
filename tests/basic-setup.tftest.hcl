run "basic-setup" {
  module {
    source = "./examples/minimal"
  }

  assert {
    condition     = module.ztna.warp_profiles != null
    error_message = "Module ID should not be null"
  }

  assert {
    condition     = module.ztna.tunnels != null
    error_message = "Tunnels output should not be null"
  }

  assert {
    condition     = module.ztna.tunnels["development"] != null
    error_message = "A tunnel for development must be created"
  }

  assert {
    condition     = module.ztna.tunnels["development"].s != null
    error_message = "A tunnel for development must have a secret"
  }

  assert {
    condition     = module.ztna.tunnels["development"].a != null
    error_message = "A tunnel for development must have a account id"
  }

  assert {
    condition     = module.ztna.tunnels["development"].t != null
    error_message = "A tunnel for development must have a tunnel id"
  }

  assert {
    condition     = can(regex("^[A-Za-z0-9+/]{43}=$", module.ztna.tunnels["development"].s))
    error_message = "A tunnel for development must have a bas64 encoded sha256secret"
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

