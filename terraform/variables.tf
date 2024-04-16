variable "resource_location" {
  type        = string
  description = "Location of all resources."
  default     = "northeurope"
}

variable "project_prefix" {
  type        = list(string)
  description = "These are short prefix that relates to the project and will be added to all resource names."
  default     = ["crc", "front"]
}

variable "env" {
  type        = list(string)
  description = "The environment currently being deployed."
  default     = ["dev"]
}

variable "custom_url_prefix" {
  type        = string
  description = "The custom URL prefix for the website."
  default     = "cv"
}

variable "azure_dns_zone_name" {
  type        = string
  description = "The name of the Azure DNS zone."
  default     = "az.macro-c.com"
}

variable "azure_dns_zone_resource_group_name" {
  type        = string
  description = "The name of the resource group the the Azure DNS zone is in."
  default     = "rg-platform-connectivity"
}

variable "logging_on" {
  type        = bool
  description = "Turning this on will create a Log Analytics Workspace and configure logging for resources."
  default     = false
}

variable "path_to_script_updateapigatwayurl" {
  type        = string
  description = "This is the relative path to the updateApiGatewayurl powershell script in the repo."
  default     = "./updateApiGatewayUrl.ps1"
}
