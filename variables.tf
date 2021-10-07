variable "letsencrypt_email" {
  type        = string
  description = "email address used to register with letsencrypt"
}

variable "letsencrypt_api_endpoint" {
  default     = "https://acme-staging-v02.api.letsencrypt.org/directory"
  description = "Let's Encrypt API endpoint, defaults to staging directory. For prod set in tfvars to: https://acme-v02.api.letsencrypt.org/directory"
}


variable "app_subdomain" {
  type        = string
  description = "subdomain where apps will be deployed.  ex: apps.clustername.basedomain.com"
}

variable "dns_provider" {
  type        = string
  description = "DNS Provider to use for ACME DNS Challenge"
  validation {
    condition     = (var.dns_provider == "azure") || (var.dns_provider == "aws") || (var.dns_provider == "ibmcloud") || (var.dns_provider == "cloudflare")
    error_message = "The dns_provider value must be one of azure, aws, ibmcloud or cloudflare."
  }
  default = null
}

variable "azure_subscription_id" {
  type        = string
  description = "Azure Subscription ID"
  default     = null
}

variable "azure_tenant_id" {
  type        = string
  description = "Azure Tenant ID"
  default     = null
}

variable "azure_client_id" {
  type        = string
  description = "Azure Client ID"
  default     = null
}

variable "azure_client_secret" {
  type        = string
  description = "Azure Client Secret"
  default     = null
}

variable "azure_resource_group" {
  type        = string
  description = "Resource Group where your public DNS zone is deployed"
  default     = null
}

variable "aws_access_key" {
  type        = string
  description = "AWS Access Key ID"
  default     = null
}

variable "aws_secret_access_key" {
  type        = string
  description = "AWS Secret Access Key"
  default     = null
}

variable "aws_session_token" {
  type        = string
  description = "AWS Session Token"
  default     = null
}

variable "ibmcloud_api_key" {
  type        = string
  description = "IBM SoftLayer API Key"
  default     = null
}

variable "ibmcloud_username" {
  type        = string
  description = "IBM Cloud SoftLayer Username"
  default     = null
}

variable "cloudflare_username" {
  type        = string
  description = "Cloudflare Username"
  default     = null
}

variable "cloudflare_api_key" {
  type        = string
  description = "Cloudflare API Key"
  default     = null
}
