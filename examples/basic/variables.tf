variable "subscription_id" {
  description = "Azure subscription GUID for the provider. Usually supplied via ARM_SUBSCRIPTION_ID instead of a literal."
  type        = string
  default     = "00000000-0000-0000-0000-000000000000"
}

variable "resource_group_name" {
  description = "Existing resource group that will hold the zone and its records."
  type        = string
  default     = "rg-dns-example"
}

variable "zone_name" {
  description = "Public DNS zone name created by this example."
  type        = string
  default     = "example.com"
}
