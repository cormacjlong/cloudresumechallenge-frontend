data "azurerm_client_config" "current" {}

locals {
  custom_url_prefix_full     = var.env == "prod" ? var.custom_url_prefix : "${var.custom_url_prefix}-${var.env}"
  api_custom_url_prefix_full = var.env == "prod" ? "${var.custom_url_prefix}-api" : "${var.custom_url_prefix}-${var.env}-api"
  common_tags = {
    Environment        = var.env
    WorkloadName       = "CloudResumeChallenge"
    DataClassification = "Public"
    Criticality        = "Non-Critical"
  }
}

# Naming module to ensure all resources have naming standard applied
module "naming" {
  source      = "Azure/naming/azurerm"
  suffix      = concat([var.env], var.project_prefix)
  unique-seed = data.azurerm_client_config.current.subscription_id
  version     = "0.4.1"
}

# Create a resource group to host the frontend resources
resource "azurerm_resource_group" "this" {
  location = var.resource_location
  name     = module.naming.resource_group.name
  tags     = local.common_tags
}

# Create a storage account to host the static website
resource "azurerm_storage_account" "this" {
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  name = module.naming.storage_account.name_unique

  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  min_tls_version          = "TLS1_2"
  blob_properties {
    delete_retention_policy {
      days = 1
    }
  }

  static_website {
    index_document = "index.html"
  }

  tags = local.common_tags
}

# Create a CDN profile to front the storage account
resource "azurerm_cdn_profile" "this" {
  name                = module.naming.cdn_profile.name_unique
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  sku                 = "Standard_Microsoft"
  tags                = local.common_tags
}

# Create a CDN endpoint to front the storage account
resource "azurerm_cdn_endpoint" "this" {
  name                = module.naming.cdn_endpoint.name_unique
  profile_name        = azurerm_cdn_profile.this.name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  origin_host_header  = azurerm_storage_account.this.primary_web_host
  querystring_caching_behaviour = "UseQueryString"

  origin {
    name      = "${azurerm_storage_account.this.name}-origin"
    host_name = azurerm_storage_account.this.primary_web_host
  }

  # Modify Global delivery rule
  global_delivery_rule {
    cache_expiration_action {
      behavior = "SetIfMissing"
      duration = "1.00:00:00"
    }
    modify_response_header_action {
      action = "Append"
      name   = "X-Content-Type-Options"
      value  = "nosniff"
    }
  }

  # Add a delivery rule that forces all traffic to use HTTPS
  delivery_rule {
    name  = "EnforceHTTPS"
    order = 1
    request_scheme_condition {
      match_values = ["HTTP"]
    }
    url_redirect_action {
      redirect_type = "Found"
      protocol      = "Https"
    }
  }

  querystring_caching_behaviour = "IgnoreQueryString"
  tags                          = local.common_tags
}

# Get the Azure DNS Zone
data "azurerm_dns_zone" "this" {
  name                = var.azure_dns_zone_name
  resource_group_name = var.azure_dns_zone_resource_group_name
}

# Create a DNS record for the CDN endpoint
resource "azurerm_dns_cname_record" "this" {
  name                = local.custom_url_prefix_full
  zone_name           = data.azurerm_dns_zone.this.name
  resource_group_name = data.azurerm_dns_zone.this.resource_group_name
  ttl                 = 3600
  target_resource_id  = azurerm_cdn_endpoint.this.id
  tags                = local.common_tags
}

# Add a delay before creation of Custom Domain to allow DNS record to propagate
resource "time_sleep" "wait_10_seconds" {
  create_duration = "10s"
  triggers = {
    cname_record = azurerm_dns_cname_record.this.fqdn
  }
  depends_on = [azurerm_dns_cname_record.this]
}

# Add Custom Domain to CDN Endpoint
resource "azurerm_cdn_endpoint_custom_domain" "this" {
  name            = "${local.custom_url_prefix_full}-custom-domain"
  cdn_endpoint_id = azurerm_cdn_endpoint.this.id
  host_name       = substr(azurerm_dns_cname_record.this.fqdn, 0, length(azurerm_dns_cname_record.this.fqdn) - 1)
  cdn_managed_https {
    certificate_type = "Dedicated"
    protocol_type    = "ServerNameIndication"
    tls_version      = "TLS12"
  }
  depends_on = [time_sleep.wait_10_seconds]
}
