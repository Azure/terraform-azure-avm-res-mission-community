variable "parent_id" {
  type        = string
  description = "The resource ID of the community to which this dedicated hub belongs."
  nullable    = false

  validation {
    condition     = can(provider::azapi::parse_resource_id("Microsoft.Mission/communities", var.parent_id))
    error_message = "The parent ID must be a valid resource ID of type Microsoft.Mission/communities."
  }
}

variable "designation" {
  type    = string
  default = "Pooled"

  validation {
    condition     = var.designation == "Pooled" || var.designation == "Reserved"
    error_message = "The designation must be one of 'Pooled' or 'Reserved'."
  }
}
