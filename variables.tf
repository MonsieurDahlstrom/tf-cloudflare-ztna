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
  description = "The CIDR block to use for private networks. Must be a /22 CIDR in a private range (10.0.0.0/8, 172.16.0.0/12, or 192.168.0.0/16)"
  type        = string
  default     = "10.0.0.0/22"

  validation {
    condition = (
      # Must be a /22 CIDR
      split("/", var.private_network_cidr)[1] == "22" &&
      # Must be in one of the private ranges
      (
        can(regex("^10\\.", var.private_network_cidr)) ||
        can(regex("^172\\.(1[6-9]|2[0-9]|3[0-1])\\.", var.private_network_cidr)) ||
        can(regex("^192\\.168\\.", var.private_network_cidr))
      ) &&
      # Must be a valid IP address (each octet 0-255)
      alltrue([
        for octet in split(".", split("/", var.private_network_cidr)[0]) :
        tonumber(octet) >= 0 && tonumber(octet) <= 255
      ])
    )
    error_message = "The private_network_cidr must be a /22 CIDR in a private range (10.0.0.0/8, 172.16.0.0/12, or 192.168.0.0/16) with valid IP octets (0-255)"
  }
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

variable "base_precedence" {
  description = "Base precedence value for access policies. Use 100 for production rules, higher values for integration testing."
  type        = number
  default     = 100
}
