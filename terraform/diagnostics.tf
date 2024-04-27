# Create a Log Analytics Workspace for Application Insights
resource "azurerm_log_analytics_workspace" "this" {
  count               = var.logging_on ? 1 : 0
  location            = azurerm_resource_group.this.location
  name                = module.naming.log_analytics_workspace.name
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  daily_quota_gb      = 1
  tags                = local.common_tags
}

# Turning on Diagnostics Settings for all resources
module "config_diagnostics" {
  count                      = var.logging_on ? 1 : 0
  source                     = "./modules/diagnostics"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this[0].id
  targets_resource_id = [
    azurerm_log_analytics_workspace.this[0].id,
    azurerm_cdn_endpoint.this.id,
    azurerm_cdn_profile.this.id,
    azurerm_storage_account.this.id,
    join("", [azurerm_storage_account.this.id, "/blobServices/default"]),
    join("", [azurerm_storage_account.this.id, "/queueServices/default"]),
    join("", [azurerm_storage_account.this.id, "/tableServices/default"]),
    join("", [azurerm_storage_account.this.id, "/fileServices/default"])
  ]
}
