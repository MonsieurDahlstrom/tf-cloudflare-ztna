# Define the private network CIDR
locals {
  private_network_cidr = "10.100.0.0/20"
}

# Configure the Cloudflare provider
provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

# Create the module instance
module "ztna" {
  source = "../../"

  # Required variables
  cloudflare_account_id = var.cloudflare_account_id
  cloudflare_api_token  = var.cloudflare_api_token
  cloudflare_zone_id    = var.cloudflare_zone_id

  # Landing zones configuration
  landingzones = var.landingzones

  # Team configurations
  teams = var.teams
}