variable "suffix" {
  description = "Optional suffix to append to all resource names for uniqueness"
  type        = string
  default     = ""
}

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

variable "private_network_cidr" {
  description = "The CIDR block to use for private networks"
  type        = string
  default     = "10.100.0.0/20"
}

variable "landingzones" {
  description = "List of landing zones with their domain names and environment names"
  type = list(object({
    domain_name = string
    environment = string
  }))
  default = []

  validation {
    condition = alltrue([
      for lz in var.landingzones : contains(["development", "staging", "production"], lz.environment)
    ])
    error_message = "Environment must be one of: development, staging, production"
  }
}

variable "teams" {
  description = "List of teams to create with their access group configurations"
  type = list(object({
    name            = string
    description     = string
    email_addresses = optional(list(string), [])
    email_domains   = optional(list(string), [])
    github_identities = optional(list(object({
      name                 = string
      identity_provider_id = string
    })), [])
    environments    = optional(list(string), ["development"])
    allowed_domains = optional(list(string), [])
  }))
  default = []

  validation {
    condition = alltrue([
      for team in var.teams : alltrue([
        for env in coalesce(team.environments, ["development"]) : contains(["development", "staging", "production"], env)
      ])
    ])
    error_message = "Environment must be one of: development, staging, production"
  }
}
