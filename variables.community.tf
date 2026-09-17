# TODO: Add parameter for Dedicated Hubs map of object

variable "address_spaces" {
  type        = list(string)
  description = "A list of address spaces for the Community resource. Each address space must be at least a /16 network. Only IPv4 is supported."
  nullable    = false

  validation {
    condition     = alltrue([for cidr in var.address_spaces : can(cidrhost(cidr, 1)) && tonumber(split("/", cidr)[1]) <= 16])
    error_message = "Each address space must be a valid IPv4 CIDR block and at least a /16 network."
  }
  validation {
    condition     = alltrue([for cidr in var.address_spaces : cidr != "192.168.0.0/16"])
    error_message = "The address space `192.168.0.0/16` is reserved for internal Community use."
  }
}

variable "approval_settings" {
  type = map(object({
    approvalPolicy           = optional(string, "NotRequired")
    minimumApproversRequired = optional(number, 0)

    mandatoryApprovers = optional(list(object({
      approverEntraId = string
    })), [])
  }))
  default = {
    communityEndpointUpdate = {
      approvalPolicy = "NotRequired"
    }
    communityMaintenanceMode = {
      approvalPolicy = "NotRequired"
    }
    connectionCreation = {
      approvalPolicy = "NotRequired"
    }
    connectionUpdate = {
      approvalPolicy = "NotRequired"
    }
    enclaveCreation = {
      approvalPolicy = "NotRequired"
    }
    enclaveEndpointUpdate = {
      approvalPolicy = "NotRequired"
    }
    enclaveMaintenanceMode = {
      approvalPolicy = "NotRequired"
    }
  }
  description = <<DESCRIPTION
Approval settings for various community operations. Each key in the map represents a specific operation, and the value is an object defining the approval requirements for that operation.

- `approvalPolicy` - (Optional) The approval policy for the operation. Can be either 'Required' or 'NotRequired'. Defaults to 'NotRequired'.
- `minimumApproversRequired` - (Optional) The minimum number of approvers required for the operation. Defaults to `1`.
- `mandatoryApprovers` - (Optional) A list of MandatoryApprover objects for the operation. Defaults to an empty list. Required if approvalPolicy is Required. Approvers must be assigned to the `Enclave Approver` role, either directly or indirectly via group membership.

Valid keys for this map include:

- `communityEndpointUpdate` - Approval settings for updates to the community endpoint.
- `communityMaintenanceMode` - Approval settings for enabling or disabling community maintenance mode.
- `connectionCreation` - Approval settings for creating new connections within the community.
- `connectionUpdate` - Approval settings for updating existing connections within the community.
- `enclaveCreation` - Approval settings for creating new enclaves within the community.
- `enclaveEndpointUpdate` - Approval settings for updating enclave endpoints within the community.
- `enclaveMaintenanceMode` - Approval settings for enabling or disabling enclave maintenance mode.
DESCRIPTION
  nullable    = false

  validation {
    condition     = alltrue([for key, setting in var.approval_settings : contains(["communityEndpointUpdate", "communityMaintenanceMode", "connectionCreation", "connectionUpdate", "enclaveCreation", "enclaveEndpointUpdate", "enclaveMaintenanceMode"], key)])
    error_message = "Invalid key in approval_settings. Valid keys are 'communityEndpointUpdate', 'communityMaintenanceMode', 'connectionCreation', 'connectionUpdate', 'enclaveCreation', 'enclaveEndpointUpdate', and 'enclaveMaintenanceMode'."
  }
  validation {
    condition     = alltrue([for key, setting in var.approval_settings : setting.approvalPolicy == "Required" ? length(setting.mandatoryApprovers) >= setting.minimumApproversRequired : true])
    error_message = "If approval is required for an operation, the number of listed approvers must be at least the minimum required."
  }
}

variable "dns_servers" {
  type        = list(string)
  default     = null
  description = "A list of DNS servers to use for the virtual networks in the Community."
}

variable "firewall_sku" {
  type        = string
  default     = "Premium"
  description = "The SKU of the Azure Firewall. Valid SKUs are `Basic`, `Standard` and `Premium`. Defaults to 'Premium'."
  nullable    = false

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.firewall_sku)
    error_message = "The firewall SKU must be either 'Basic', 'Standard' or 'Premium'."
  }
}

variable "governed_service_list" {
  type = list(object({
    service_id    = string
    option        = string
    enforcement   = optional(string, "Enabled")
    policy_action = optional(string, "Enforce")
  }))
  default     = []
  description = <<DESCRIPTION
A list of governed services within the community. Each item in the list represents a specific governed service, and the value is an object defining the service details.

- `service_id` - One of 'AKS', 'AppService', 'AzureFirewalls', 'ContainerRegistry', 'CosmosDB', 'DataConnectors', 'Insights', 'KeyVault', 'Logic', 'MicrosoftSQL', 'Monitoring', 'PostgreSQL', 'PrivateDNSZones', 'ServiceBus', 'Storage'
- `option` - Defines whether the service is permitted. Accepted values are 'Allow', 'Deny', 'ExceptionOnly', and 'NotApplicable'.
- `enforcement` - (Optional) Defines if the initiative is enforced. Accepted values are 'Enabled' and 'Disabled'. Defaults to `Enabled`.
- `policy_action` - (Optional) Defines the policy action to take. Accepted values are 'AuditOnly', 'Enforce' and 'None'. Defaults to `Enforce`.
DESCRIPTION

  validation {
    condition = alltrue([
      for service in var.governed_service_list : contains(["AKS", "AppService", "AzureFirewalls", "ContainerRegistry", "CosmosDB", "DataConnectors", "Insights", "KeyVault", "Logic", "MicrosoftSQL", "Monitoring", "PostgreSQL", "PrivateDNSZones", "ServiceBus", "Storage"], service.service_id)
    ])
    error_message = "Each governed service must have a valid service_id from 'AKS', 'AppService', 'AzureFirewalls', 'ContainerRegistry', 'CosmosDB', 'DataConnectors', 'Insights', 'KeyVault', 'Logic', 'MicrosoftSQL', 'Monitoring', 'PostgreSQL', 'PrivateDNSZones', 'ServiceBus', or 'Storage'."
  }
}

variable "maintenance_mode_configuration" {
  type = object({
    mode          = string
    justification = optional(string, null)
    principals    = list(string)
  })
  default = {
    mode       = "Off"
    principals = []
  }
  description = <<DESCRIPTION
Configuration for the Community's maintenance mode.

- `mode` - Defines the maintenance mode status. Accepted values are 'Off', 'General', and 'Advanced'.
- `justification` - (Optional) Provides a justification for the maintenance mode. Required when `mode` is not 'Off'. Defaults to `null`. Allowed values are 'Off', 'Governance', and 'Networking'.
- `principals` - A list of principals (users, groups, or service principals) affected by the maintenance mode.
DESCRIPTION
}

variable "policy_override" {
  type        = string
  default     = "None"
  description = <<DESCRIPTION
Policy override setting for the community. Specifies whether to allow enclave-specific policies to override community policies. Defaults to `None`.
DESCRIPTION
  nullable    = false

  validation {
    condition     = contains(["None", "Enclave"], var.policy_override)
    error_message = "The policy_override must be one of 'None', 'Enclave'."
  }
}
