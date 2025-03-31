variables {
  private_network_cidr = "10.0.0.0/22"
}

run "valid_cidrs" {
  command = plan

  assert {
    condition     = var.private_network_cidr != null
    error_message = "CIDR should be valid"
  }
}

run "invalid_cidr_wrong_mask" {
  command = plan
  variables {
    private_network_cidr = "10.0.0.0/24"
  }
  expect_failures = [
    var.private_network_cidr
  ]
}

run "invalid_cidr_not_private" {
  command = plan
  variables {
    private_network_cidr = "11.0.0.0/22"
  }
  expect_failures = [
    var.private_network_cidr
  ]
}

run "invalid_cidr_wrong_172_range" {
  command = plan
  variables {
    private_network_cidr = "172.15.0.0/22"
  }
  expect_failures = [
    var.private_network_cidr
  ]
}

run "invalid_cidr_wrong_192_range" {
  command = plan
  variables {
    private_network_cidr = "192.167.0.0/22"
  }
  expect_failures = [
    var.private_network_cidr
  ]
}

run "invalid_cidr_invalid_ip" {
  command = plan
  variables {
    private_network_cidr = "256.0.0.0/22"
  }
  expect_failures = [
    var.private_network_cidr
  ]
} 