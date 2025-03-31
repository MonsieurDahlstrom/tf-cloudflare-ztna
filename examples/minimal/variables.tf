variable "cloudflare_api_token" {
  description = "Cloudflare API token with sufficient permissions to manage Zero Trust resources"
  type        = string
  sensitive   = true
}

variable "cloudflare_account_id" {
  description = "Cloudflare account ID where Zero Trust resources will be deployed"
  type        = string
}

variable "cloudflare_zone_id" {
  description = "Cloudflare zone ID where Zero Trust resources will be deployed"
  type        = string
  default     = ""
}

variable "landingzones" {
  description = "List of landing zones with their domain names and environment names"
  type = list(object({
    domain_name = string
    environment = string
  }))
  default = []
}

variable "teams" {
  description = "List of teams to create with their access group configurations"
  type = list(object({
    name            = string
    description     = string
    email_addresses = list(string)
    environments    = list(string)
    allowed_domains = list(string)
  }))
  default = [
    {
      name            = "engineering"
      description     = "Engineering team"
      email_addresses = ["engineering@example.com"]
      environments    = ["development", "staging"]
      allowed_domains = ["example.com", "staging.example.com"]
    },
    {
      name            = "devops"
      description     = "DevOps team"
      email_addresses = ["devops@example.com"]
      environments    = ["development", "staging", "production"]
      allowed_domains = ["example.com", "staging.example.com", "prod.example.com"]
    },
    {
      name            = "security"
      description     = "Security team"
      email_addresses = ["security@example.com"]
      environments    = ["development", "staging", "production"]
      allowed_domains = ["example.com", "staging.example.com", "prod.example.com"]
    }
  ]
}

variable "base_precedence" {
  description = "Base precedence for the access policies"
  type        = number
}

