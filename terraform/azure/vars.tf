variable "AZURE_SUBSCRIPTION_ID" {
  type = string
}

variable "RESOURCE_GROUP_NAME" {
  type = string
}

variable "LOCATION" {
  type = string
}

variable "SA_ACCOUNT_NAME" {
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
  type = object({
    Application_Id   = string
    Application_Name = string
    Cost_Center      = string
    Expiration       = string
    Owning_Role      = string
    Stage            = string
    WBS_Element      = string
    BIA              = string
  })
  description = "Tags to be added in all resources"
  default = {
    Application_Id   = "POC-Exception"
    Application_Name = "POC-Exception"
    Cost_Center      = "1000501399"
    Expiration       = "11/16/2021"
    Owning_Role      = "GBSG-Consumer-AZ-RG-CS-MW-ACE-NA-NonProd"
    Stage            = "POC"
    WBS_Element      = ""
    BIA              = "{\"Confidentiality\":\"\",\"Integrity\":\"\",\"Availability\":\"\"}"
  }
}
