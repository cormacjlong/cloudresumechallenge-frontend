data "azurerm_client_config" "current" {}

data "azurerm_subscription" "current" {  
}

module "naming" {
  source  = "Azure/naming/azurerm"
  suffix = [ var.project_prefix, var.env ]
  unique-seed = "${data.azurerm_subscription.current.subscription_id}"
}

resource "azurerm_resource_group" "rg" {
  location = var.resource_location
  name     = module.naming.resource_group.name
}

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

// Files will be uploaded using Workflow instead

/* resource "azurerm_storage_blob" "index" {
  name                   = "index.html"
  storage_account_name   = azurerm_storage_account.storage_account.name
  storage_container_name = "$web"
  type                   = "Block"
  content_type           = "text/html"
  source                 = "../website/index.html"
}

resource "azurerm_storage_blob" "css" {
  name                   = "style.css"
  storage_account_name   = azurerm_storage_account.storage_account.name
  storage_container_name = "$web"
  type                   = "Block"
  content_type           = "text/css"
  source                 = "../website/style.css"
}

resource "azurerm_storage_blob" "images" {
  for_each = fileset("../website", "*.png")

  name                   = each.value
  storage_account_name   = azurerm_storage_account.storage_account.name
  storage_container_name = "$web"
  type                   = "Block"
  content_type           = "image/png"
  source                 = "../website/${each.value}"
} */
