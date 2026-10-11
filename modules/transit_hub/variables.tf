variable "name" {
  type        = string
  description = "The name of this resource."

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]*[a-zA-Z0-9]$", var.name))
    error_message = "The name must start with a letter, can contain letters, numbers, and hyphens, but must not end with a hyphen."
  }
  validation {
    condition     = length(var.name) <= 30 && length(var.name) >= 3
    error_message = "The name must be between 3 and 30 characters long."
  }
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
  nullable    = false
}
