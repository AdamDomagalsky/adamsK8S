# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.65.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  skip_provider_registration = "true"
  subscription_id            = var.AZURE_SUBSCRIPTION_ID
  features {}
}
# resource "azurerm_resource_group" "AZ-RG-MW-Sandbox-01" {
#   # (resource arguments)
# }
data "azurerm_resource_group" "rg" {
  name = var.RESOURCE_GROUP_NAME
}
data "azurerm_client_config" "current" {
}
output "clientid" {
  value = data.azurerm_client_config.current.client_id
}
output "tenantid" {
  value = data.azurerm_client_config.current.tenant_id
}
output "subscriptionid" {
  value = data.azurerm_client_config.current.subscription_id
}
output "objectid" {
  value = data.azurerm_client_config.current.object_id
}
# output "azurerm_resource_group" {
#   value = "${data.azurerm_resource_group.rg.name}"
# }

resource "azurerm_container_registry" "acr" {
  name                = "acr${var.UNIQ_NAME}"
  resource_group_name = var.RESOURCE_GROUP_NAME
  location            = var.LOCATION
  sku                 = "Basic"
  tags                = var.MAIN_TAGS
}

resource "azurerm_log_analytics_workspace" "law" {
  name                = "law-${var.UNIQ_NAME}"
  location            = var.LOCATION
  resource_group_name = var.RESOURCE_GROUP_NAME
}



resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-${var.UNIQ_NAME}"
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
      log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
    }
  }
}

# attach acr https://stackoverflow.com/questions/59978060/how-to-give-permissions-to-aks-to-access-acr-via-terraform
resource "azurerm_role_assignment" "aks_to_acr" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}
