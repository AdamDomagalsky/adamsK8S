# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.90.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  skip_provider_registration = "true"
  subscription_id            = var.AZURE_SUBSCRIPTION_ID

  features {}
}
resource "azurerm_resource_group" "AZ-RG-MW-Sandbox-01" {
  # (resource arguments)
  name     = var.RESOURCE_GROUP_NAME
  location = var.LOCATION
  tags     = var.MAIN_TAGS
  lifecycle {
    ignore_changes = [tags]
  }
}
data "azurerm_resource_group" "rg" {
  name = var.RESOURCE_GROUP_NAME
}
data "azurerm_client_config" "current" {
}
resource "azurerm_container_registry" "acrAdams" {
  name                = "acr${var.UNIQ_NAME}"
  resource_group_name = var.RESOURCE_GROUP_NAME
  location            = var.LOCATION
  sku                 = "Basic"
  tags                = var.MAIN_TAGS
}

resource "azurerm_log_analytics_workspace" "lawAdams" {
  name                = "law${var.UNIQ_NAME}"
  location            = var.LOCATION
  resource_group_name = var.RESOURCE_GROUP_NAME
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_kubernetes_cluster" "aksAdams" {
  name                = "aks${var.UNIQ_NAME}"
  location            = var.LOCATION
  resource_group_name = var.RESOURCE_GROUP_NAME
  dns_prefix          = var.DNS_PREFIX

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }


  identity {
    type = "SystemAssigned"
  }

  tags = var.MAIN_TAGS

  addon_profile {
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.lawAdams.id
    }
  }
}

# attach acr https://stackoverflow.com/questions/59978060/how-to-give-permissions-to-aks-to-access-acr-via-terraform
resource "azurerm_role_assignment" "aks_to_acr" {
  scope                = azurerm_container_registry.acrAdams.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aksAdams.kubelet_identity[0].object_id
}
