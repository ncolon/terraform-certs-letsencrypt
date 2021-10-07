terraform {
  required_providers {
    acme = {
      source  = "vancluever/acme"
      version = "2.6.0"
    }
  }
}

provider "acme" {
  server_url = var.letsencrypt_api_endpoint
}

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "reg" {
  account_key_pem = tls_private_key.private_key.private_key_pem
  email_address   = var.letsencrypt_email
}

resource "acme_certificate" "app_subdomain_certificate_azure" {
  count = local.azure_configured ? 1 : 0

  account_key_pem           = acme_registration.reg.account_key_pem
  common_name               = var.app_subdomain
  subject_alternative_names = ["*.${var.app_subdomain}"]

  dns_challenge {
    provider = "azure"

    config = {
      AZURE_CLIENT_ID       = var.azure_client_id
      AZURE_CLIENT_SECRET   = var.azure_client_secret
      AZURE_ENVIRONMENT     = "public"
      AZURE_RESOURCE_GROUP  = var.azure_resource_group
      AZURE_SUBSCRIPTION_ID = var.azure_subscription_id
      AZURE_TENANT_ID       = var.azure_tenant_id
    }
  }
}

resource "acme_certificate" "app_subdomain_certificate_aws" {
  count = local.aws_configured ? 1 : 0

  account_key_pem           = acme_registration.reg.account_key_pem
  common_name               = var.app_subdomain
  subject_alternative_names = ["*.${var.app_subdomain}"]

  dns_challenge {
    provider = "route53"

    config = {
      AWS_ACCESS_KEY_ID     = var.aws_access_key
      AWS_SECRET_ACCESS_KEY = var.aws_secret_access_key
    }
  }
}

# resource "acme_certificate" "app_subdomain_certificate_ibmcloud" {
#   count = local.ibmcloud_configured ? 1 : 0

#   account_key_pem           = acme_registration.reg.account_key_pem
#   common_name               = var.app_subdomain
#   subject_alternative_names = ["*.${var.app_subdomain}"]

#   dns_challenge {
#     provider = "ibmcloud"

#     config = {
#       SOFTLAYER_API_KEY  = var.ibmcloud_api_key
#       SOFTLAYER_USERNAME = var.ibmcloud_username
#     }
#   }
# }

resource "acme_certificate" "app_subdomain_certificate_cloudflare" {
  count = local.cloudflare_configured ? 1 : 0

  account_key_pem           = acme_registration.reg.account_key_pem
  common_name               = var.app_subdomain
  subject_alternative_names = ["*.${var.app_subdomain}"]

  dns_challenge {
    provider = "cloudflare"

    config = {
      CF_API_KEY   = var.cloudflare_api_key
      CF_API_EMAIL = var.cloudflare_username
    }
  }
}

locals {
  azure_configured = var.dns_provider == "azure" && (var.azure_client_id != null) && (var.azure_client_secret != null) && (var.azure_client_secret != null) && (var.azure_client_secret != null) ? true : false
  aws_configured   = var.dns_provider == "aws" && (var.aws_access_key != null) && (var.aws_secret_access_key != null) ? true : false
  # ibmcloud_configured   = var.dns_provider == "ibmcloud" && (var.ibmcloud_api_key != null) && (var.ibmcloud_username != null) ? true : false
  cloudflare_configured = var.dns_provider == "cloudflare" && (var.cloudflare_api_key != null) && (var.cloudflare_username != null) ? true : false
  router_cert = local.azure_configured ? acme_certificate.app_subdomain_certificate_azure[0].certificate_pem : (
    local.aws_configured ? acme_certificate.app_subdomain_certificate_aws[0].certificate_pem : (
      # local.ibmcloud_configured ? acme_certificate.app_subdomain_certificate_ibmcloud[0].certificate_pem : (
      local.cloudflare_configured ? acme_certificate.app_subdomain_certificate_cloudflare[0].certificate_pem : ""
  ))
  router_key = local.azure_configured ? acme_certificate.app_subdomain_certificate_azure[0].private_key_pem : (
    local.aws_configured ? acme_certificate.app_subdomain_certificate_aws[0].private_key_pem : (
      # local.ibmcloud_configured ? acme_certificate.app_subdomain_certificate_ibmcloud[0].private_key_pem : (
      local.cloudflare_configured ? acme_certificate.app_subdomain_certificate_cloudflare[0].private_key_pem : ""
  ))
  router_issuer = local.azure_configured ? acme_certificate.app_subdomain_certificate_azure[0].issuer_pem : (
    local.aws_configured ? acme_certificate.app_subdomain_certificate_aws[0].issuer_pem : (
      # local.ibmcloud_configured ? acme_certificate.app_subdomain_certificate_ibmcloud[0].issuer_pem : (
      local.cloudflare_configured ? acme_certificate.app_subdomain_certificate_cloudflare[0].issuer_pem : ""
  ))
}
