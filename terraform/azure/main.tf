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
    subscription_id            = "${var.azure_subscription_id}"
  features {}
}

data "azurerm_resource_group" "rg" {
  name = "${var.resource_group}"
}

# output "azurerm_resource_group" {
#   value = "${data.azurerm_resource_group.rg.name}"
# }

resource "azurerm_container_registry" "acr" {
  name                = "acr${var.uniqName}"
  resource_group_name = var.resource_group
  location            = var.location
  sku                 = "Basic"
  tags = var.mainTags
}

resource "azurerm_log_analytics_workspace" "law" {
  name                = "law-${var.uniqName}"
  location            = var.location
  resource_group_name = var.resource_group
}



resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-${var.uniqName}"
  location            = var.location
  resource_group_name = var.resource_group
  dns_prefix          = var.dns_prefix

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }


  identity {
    type = "SystemAssigned"
  }

  tags = var.mainTags
  
  addon_profile {
	oms_agent {
      enabled = true
	  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
    }
  }
}

# attach acr https://stackoverflow.com/questions/59978060/how-to-give-permissions-to-aks-to-access-acr-via-terraform
resource "azurerm_role_assignment" "aks_to_acr" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}
