data "azurerm_client_config" "current" {}

data "azurerm_subscription" "current" {}

locals {
  custom_url_prefix_full     = var.env == "prod" ? var.custom_url_prefix : "${var.custom_url_prefix}-${var.env[0]}"
  api_custom_url_prefix_full = var.env == "prod" ? "${var.custom_url_prefix}-api" : "${var.custom_url_prefix}-${var.env[0]}-api"
}

# Naming module to ensure all resources have naming standard applied
module "naming" {
  source      = "Azure/naming/azurerm"
  suffix      = concat(var.env, var.project_prefix)
  unique-seed = data.azurerm_subscription.current.subscription_id
}

# Create a resource group to host the frontend resources
resource "azurerm_resource_group" "rg" {
  location = var.resource_location
  name     = module.naming.resource_group.name
}

# Create a storage account to host the static website
resource "azurerm_storage_account" "storage_account" {
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  name = module.naming.storage_account.name_unique

  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  min_tls_version          = "TLS1_2"

  static_website {
    index_document = "index.html"
  }

}

# Create a CDN profile to front the storage account
resource "azurerm_cdn_profile" "cdn_profile" {
  name                = module.naming.cdn_profile.name_unique
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard_Microsoft"
}

# Create a CDN endpoint to front the storage account
resource "azurerm_cdn_endpoint" "cdn_endpoint" {
  name                = module.naming.cdn_endpoint.name_unique
  profile_name        = azurerm_cdn_profile.cdn_profile.name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  origin_host_header  = azurerm_storage_account.storage_account.primary_web_host

  origin {
    name      = "${azurerm_storage_account.storage_account.name}-origin"
    host_name = azurerm_storage_account.storage_account.primary_web_host
  }

  querystring_caching_behaviour = "IgnoreQueryString"
}

# Get the Azure DNS Zone
data "azurerm_dns_zone" "dns_zone" {
  name                = var.azure_dns_zone_name
  resource_group_name = var.azure_dns_zone_resource_group_name
}

# Create a DNS record for the CDN endpoint
resource "azurerm_dns_cname_record" "cdn_dns_record" {
  name                = local.custom_url_prefix_full
  zone_name           = data.azurerm_dns_zone.dns_zone.name
  resource_group_name = data.azurerm_dns_zone.dns_zone.resource_group_name
  ttl                 = 3600
  target_resource_id  = azurerm_cdn_endpoint.cdn_endpoint.id
}

# Add Custom Domain to CDN Endpoint
resource "azurerm_cdn_endpoint_custom_domain" "cdn_custom_domain" {
  name            = "${local.custom_url_prefix_full}-custom-domain"
  cdn_endpoint_id = azurerm_cdn_endpoint.cdn_endpoint.id
  host_name       = substr(azurerm_dns_cname_record.cdn_dns_record.fqdn, 0, length(azurerm_dns_cname_record.cdn_dns_record.fqdn) - 1)
  cdn_managed_https {
    certificate_type = "Dedicated"
    protocol_type    = "ServerNameIndication"
    tls_version      = "TLS12"
  }
}
