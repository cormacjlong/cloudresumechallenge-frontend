terraform {
  required_version = ">=1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.97.1"
    }

    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~>0.11.1"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-platform-management"
    storage_account_name = "stterraformgj5f"
    container_name       = "terraform-state"
    key                  = "crc-frontend.tfstate"
    use_oidc             = true
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  use_oidc = true
  features {}
}
