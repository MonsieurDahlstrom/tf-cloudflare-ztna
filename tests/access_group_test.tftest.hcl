variables {
  cloudflare_account_id = "test-account-id"
  suffix = "test"
  private_network_cidr = "10.0.0.0/22"
  landingzones = [
    {
      domain_name = "test.com"
      environment = "development"
    }
  ]
}

run "verify_access_group_with_both_email_types" {
  command = plan

  variables {
    teams = [
      {
        name = "test-team"
        description = "Test team with both email types"
        email_addresses = ["user@example.com"]
        email_domains = ["example.com"]
        environments = ["development"]
      }
    ]
  }

  assert {
    condition     = cloudflare_zero_trust_access_group.teams["test-team"].include[0].email[0] == "user@example.com"
    error_message = "Email address should be set correctly"
  }

  assert {
    condition     = cloudflare_zero_trust_access_group.teams["test-team"].include[0].email_domain[0] == "example.com"
    error_message = "Email domain should be set correctly"
  }
}

run "verify_access_group_with_only_email_addresses" {
  command = plan

  variables {
    teams = [
      {
        name = "test-team"
        description = "Test team with only email addresses"
        email_addresses = ["user@example.com"]
        email_domains = null
        environments = ["development"]
      }
    ]
  }

  assert {
    condition     = cloudflare_zero_trust_access_group.teams["test-team"].include[0].email[0] == "user@example.com"
    error_message = "Email address should be set correctly"
  }

  assert {
    condition     = cloudflare_zero_trust_access_group.teams["test-team"].include[0].email_domain == null
    error_message = "Email domain should be null"
  }
}

run "verify_access_group_with_only_email_domains" {
  command = plan

  variables {
    teams = [
      {
        name = "test-team"
        description = "Test team with only email domains"
        email_addresses = null
        email_domains = ["example.com"]
        environments = ["development"]
      }
    ]
  }

  assert {
    condition     = cloudflare_zero_trust_access_group.teams["test-team"].include[0].email == null
    error_message = "Email address should be null"
  }

  assert {
    condition     = cloudflare_zero_trust_access_group.teams["test-team"].include[0].email_domain[0] == "example.com"
    error_message = "Email domain should be set correctly"
  }
}

run "verify_access_group_with_no_email_types" {
  command = plan

  variables {
    teams = [
      {
        name = "test-team"
        description = "Test team with no email types"
        email_addresses = null
        email_domains = null
        environments = ["development"]
      }
    ]
  }

  assert {
    condition     = cloudflare_zero_trust_access_group.teams["test-team"].include[0].email == null
    error_message = "Email address should be null"
  }

  assert {
    condition     = cloudflare_zero_trust_access_group.teams["test-team"].include[0].email_domain == null
    error_message = "Email domain should be null"
  }
} 