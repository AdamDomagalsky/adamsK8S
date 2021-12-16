variable "AZURE_SUBSCRIPTION_ID" {
  type = string
}

variable "RESOURCE_GROUP_NAME" {
  type = string
}

variable "LOCATION" {
  type = string
}

variable "DNS_PREFIX" {
  type = string
}

variable "ENV" {
  type = string
}

variable "UNIQ_NAME" {
  type        = string
  description = "Some of resources must have unique names in global scope"
}

variable "MAIN_TAGS" {
  type        = map(string)
  description = "Tags to be added in all resources"
}
