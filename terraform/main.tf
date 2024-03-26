data "azurerm_client_config" "current" {}

data "azurerm_subscription" "current" {}

# Naming module to ensure all resources have naming standard applied
module "naming" {
  source      = "Azure/naming/azurerm"
  suffix      = [var.env, var.project_prefix]
  unique-seed = data.azurerm_subscription.current.subscription_id
}

# Create a resource group to host the storage account and CDN profile
resource "azurerm_resource_group" "rg" {
  location = var.resource_location
  name     = "${module.naming.resource_group.name}-frontend"
}

# Create a storage account to host the static website
resource "azurerm_storage_account" "storage_account" {
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  name = module.naming.storage_account.name_unique

  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

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

  dynamic "endpoint" {
    for_each = var.env == "prod" ? [1] : []
    content {
      name                   = "${azurerm_storage_account.storage_account.name}-endpoint"
      is_http_allowed        = false
      is_https_allowed       = true
      origin_host_header     = azurerm_storage_account.storage_account.primary_web_endpoint
      origin_host_header_cdn = azurerm_storage_account.storage_account.primary_web_endpoint
      origin_path            = ""
      content_types_to_compress = [
        "text/plain",
        "text/html",
        "text/css",
        "application/javascript",
        "application/x-javascript",
        "application/javascript; charset=utf-8",
        "application/x-javascript; charset=utf-8",
        "text/javascript",
        "text/javascript; charset=utf-8",
        "text/javascript; charset=utf-8",
        "application/json",
        "application/json; charset=utf-8",
        "application/json; charset=utf-8",
        "application/xml",
        "application/xml; charset=utf-8",
        "application/xml; charset=utf-8",
        "text/xml"
      ]
    }
  }
}
