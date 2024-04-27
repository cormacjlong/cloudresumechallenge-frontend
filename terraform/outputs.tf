output "resource_group_name" {
  value = azurerm_resource_group.this.name
}

output "storage_account_name" {
  value = azurerm_storage_account.this.name
}

output "primary_web_host" {
  value = azurerm_storage_account.this.primary_web_host
}

output "cdn_endpoint" {
  value = azurerm_cdn_endpoint.this.name
}

output "cdn_profile_name" {
  value = azurerm_cdn_profile.this.name
}

output "api_custom_domain_url" {
  value = "https://${local.api_custom_url_prefix_full}.${var.azure_dns_zone_name}/api/getvisitor"
}
