run "basic-setup" {
  module {
    source = "./examples/minimal"
  }

  assert {
    condition     = module.zero_trust.virtual_networks != null
    error_message = "Module ID should not be null"
  }
}

