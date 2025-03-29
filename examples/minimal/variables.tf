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
}

variable "landingzones" {
  description = "List of landing zones with their domain names and environment names"
  type = list(object({
    domain_name = string
    environment = string
  }))
  default = [
    {
      domain_name = "dev.example.com"
      environment = "development"
    },
    {
      domain_name = "staging.example.com"
      environment = "staging"
    },
    {
      domain_name = "prod.example.com"
      environment = "production"
    }
  ]
} 