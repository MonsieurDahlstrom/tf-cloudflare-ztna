variables {
  cloudflare_account_id = "test-account-id"
  suffix                = "test"
  private_network_cidr  = "10.0.0.0/22"
  landingzones = [
    {
      domain_name = "test.com"
      environment = "development"
    }
  ]
}

run "verify_wirefilter_with_email_and_user_group" {
  command = plan

  variables {
    teams = [
      {
        name            = "test-team"
        description     = "Test team with email and domain in wirefilter"
        email_addresses = ["mathias@monsieurdahlstrom.com", "sven@monsieurdahlstrom.com"]
        user_groups     = ["13d00541-db1e-422c-a3ec-ef3814aabdc4"]
        environments    = ["development"]
      }
    ]
  }

  assert {
    condition     = can(regex("identity.email", cloudflare_zero_trust_device_custom_profile.teams["test-team"].match))
    error_message = "Wirefilter should include email"
  }

  assert {
    condition     = can(regex("mathias@monsieurdahlstrom.com", cloudflare_zero_trust_device_custom_profile.teams["test-team"].match))
    error_message = "Wirefilter should include the specific email address"
  }

  assert {
    condition     = cloudflare_zero_trust_device_custom_profile.teams["test-team"].match == "any(identity.groups.id[*] in {\"13d00541-db1e-422c-a3ec-ef3814aabdc4\"}) or identity.email in {\"mathias@monsieurdahlstrom.com\" \"sven@monsieurdahlstrom.com\"}"
    error_message = "Wirefilter should include the specific user group"
  }
}

run "verify_wirefilter_with_only_email" {
  command = plan

  variables {
    teams = [
      {
        name            = "test-team"
        description     = "Test team with only email in wirefilter"
        email_addresses = ["user@example.com"]
        environments    = ["development"]
      }
    ]
  }

  assert {
    condition     = can(regex("identity.email", cloudflare_zero_trust_device_custom_profile.teams["test-team"].match))
    error_message = "Wirefilter should include email"
  }

  assert {
    condition     = can(regex("user@example.com", cloudflare_zero_trust_device_custom_profile.teams["test-team"].match))
    error_message = "Wirefilter should include the specific email address"
  }

  assert {
    condition     = cloudflare_zero_trust_device_custom_profile.teams["test-team"].match == "identity.email in {\"user@example.com\"}"
    error_message = "Wirefilter should include the specific domain"
  }
}

run "verify_wirefilter_with_multiple_emails" {
  command = plan

  variables {
    teams = [
      {
        name            = "test-team"
        description     = "Test team with multiple emails in wirefilter"
        email_addresses = ["user1@example.com", "user2@example.com"]
        environments    = ["development"]
      }
    ]
  }

  assert {
    condition     = can(regex("user1@example.com", cloudflare_zero_trust_device_custom_profile.teams["test-team"].match))
    error_message = "Wirefilter should include the first email address"
  }

  assert {
    condition     = can(regex("user2@example.com", cloudflare_zero_trust_device_custom_profile.teams["test-team"].match))
    error_message = "Wirefilter should include the second email address"
  }

  assert {
    condition     = cloudflare_zero_trust_device_custom_profile.teams["test-team"].match == "identity.email in {\"user1@example.com\" \"user2@example.com\"}"
    error_message = "Wirefilter should include the specific domain"
  }
}

run "verify_wirefilter_with_only_user_group" {
  command = plan

  variables {
    teams = [
      {
        name         = "test-team"
        description  = "Test team with only email in wirefilter"
        user_groups  = ["test-user-group"]
        environments = ["development"]
      }
    ]
  }

  assert {
    condition     = can(regex("identity.groups", cloudflare_zero_trust_device_custom_profile.teams["test-team"].match))
    error_message = "Wirefilter should include identity.groups"
  }

  assert {
    condition     = can(regex("test-user-group", cloudflare_zero_trust_device_custom_profile.teams["test-team"].match))
    error_message = "Wirefilter should include the user group"
  }

  assert {
    condition     = cloudflare_zero_trust_device_custom_profile.teams["test-team"].match == "any(identity.groups.id[*] in {\"test-user-group\"})"
    error_message = "Wirefilter should include the specific user group"
  }
}