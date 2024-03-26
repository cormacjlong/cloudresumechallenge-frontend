variable "resource_location" {
  type        = string
  description = "Location of all resources."
  default     = "northeurope"
}

variable "resource_group_name_prefix" {
  type        = string
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
  default     = "rg"
}

variable "project_prefix" {
  type        = string
  description = "This is a short prefix that relates to the project and will be added to all resource names."
  default     = "cloudresume"
}

variable "env" {
  type        = string
  description = "The environment currently being deplyed."
  default     = "dev"
}
