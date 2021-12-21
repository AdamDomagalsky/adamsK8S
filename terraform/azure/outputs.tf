
output "uniqName" {
  value = var.UNIQ_NAME
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

output "cluster_name" {
  value = resource.azurerm_kubernetes_cluster.aksAdams.name
}

output "resource-group" {
  value = var.RESOURCE_GROUP_NAME
}
