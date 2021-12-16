variable "azure_subscription_id" {
  type = string
}

variable "resource_group" {
  type = string
}

variable "location" {
  type = string
}

variable "dns_prefix" {
  type = string
}

variable "env" {
  type = string
}

variable "uniqName" {
  type        = string
  description = "Some of resources must have unique names in global scope"
}

variable "mainTags" {
  type        = map(string)
  description = "Tags to be added in all resources"
}
