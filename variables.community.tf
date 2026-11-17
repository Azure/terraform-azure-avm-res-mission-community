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
  default     = {}
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
    justification = string
    principals = list(object({
      id   = string
      type = string
    }))
  })

  # TODO: Remove "On" and "CanNotDelete" from the accepted values for maintenance mode.
  default = {
    mode          = "Off"
    justification = "Off"
    principals    = []
  }
  description = <<DESCRIPTION
Configuration for the Community's maintenance mode.

- `mode` - Defines the maintenance mode status. Accepted values are 'On', 'Off', 'General', 'CanNotDelete', and 'Advanced'.
- `justification` - (Optional) Provides a justification for the maintenance mode. Required when `mode` is not 'Off'. Defaults to `Off`. Allowed values are 'Off', 'Governance', 'Networking' and 'NotSpecified'.
- `principals` - A list of principal objects with `id` and `type` attributes representing the affected principals.
DESCRIPTION

  validation {
    condition     = var.maintenance_mode_configuration.mode == "Off" || var.maintenance_mode_configuration.justification != ""
    error_message = "If maintenance mode is not 'Off', a justification must be provided."
  }

  validation {
    condition     = var.maintenance_mode_configuration.mode == "Off" || length(var.maintenance_mode_configuration.principals) > 0
    error_message = "If maintenance mode is not 'Off', at least one principal must be provided."
  }

  validation {
    condition     = contains(["On", "Off", "General", "CanNotDelete", "Advanced"], var.maintenance_mode_configuration.mode)
    error_message = "The mode must be one of 'On', 'Off', 'General', 'CanNotDelete', or 'Advanced'."
  }

  validation {
    condition     = contains(["Off", "Governance", "Networking", "NotSpecified"], var.maintenance_mode_configuration.justification)
    error_message = "The justification must be one of 'Off', 'Governance', 'Networking', or 'NotSpecified'."
  }

  validation {
    condition = alltrue(flatten([
      for principal in var.maintenance_mode_configuration.principals : [
        can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", principal.id))
      ]
    ]))
    error_message = "The principal ID must be an Entra object ID formatted as a GUID."
  }

  validation {
    condition = alltrue(flatten([
      for principal in var.maintenance_mode_configuration.principals : [
        contains(["Group", "ServicePrincipal", "User"], principal.type)
      ]
    ]))
    error_message = "The principal type must be one of 'Group', 'ServicePrincipal', or 'User'."
  }
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

variable "community_role_assignments" {
  type = list(object({
    condition = optional(string, null)
    principals = list(object({
      id   = string
      type = string
    }))
    role_definition_id = string
  }))
  default     = []
  description = <<DESCRIPTION
A list of role assignments for Community administrators. Use this variable instead of the default AVM `role_assignments` variable when granting Community administrator access because `community_role_assignments` creates role assignments on the managed resource group associated with the Community, whereas `role_assignments` creates role assignments scoped to the Community resource only.

- `condition` - (Optional) The condition under which the principals can be granted permission.
- `principals` - A list of principals to which the role definition is assigned.
  - `id` - The object ID of the principal.
  - `type` - The principal type. Possible values are `Group`, `ServicePrincipal`, and `User`.
- `role_definition_id` - The role definition identifier to assign to the principals.
DESCRIPTION
  nullable    = false

  validation {
    condition = alltrue(flatten([
      for role_assignment in var.community_role_assignments : [
        for principal in role_assignment.principals :
        contains(["Group", "ServicePrincipal", "User"], principal.type)
      ]
    ]))
    error_message = "Each principal type must be one of: `Group`, `ServicePrincipal`, or `User`."
  }
}

variable "monitoring_settings" {
  type = object({
    diagnosticDestinations = list(object({
      customWorkspaceResourceId = optional(string, null)
      destinationType           = string
      diagnosticSettingsName    = optional(string, null)
    }))
    flowLogDestination = object({
      customWorkspaceResourceId = optional(string, null)
      destinationType           = string
      diagnosticSettingsName    = optional(string, null)
    })
  })

  default = null

  description = <<DESCRIPTION
Monitoring settings for the community for diagnostic logging and network flow logging. If you do not provide a value, diagnostic and flow logging will use a Community Log Analytics workspace.

- `diagnosticDestinations` - A list of diagnostic destinations.
  - `customWorkspaceResourceId` - The resource ID of a Log Analytics workspace. Required and must be a valid workspace resource ID when `destinationType` is `CustomWorkspace`; otherwise optional.
  - `destinationType` - The type of the diagnostic destination. One of `CommunityWorkspace`, `CustomWorkspace`, `EnclaveWorkspace`.
  - `diagnosticSettingsName` - (Optional) The name of the diagnostic setting.
- `flowLogDestination` - The destination for network flow logs.
  - `customWorkspaceResourceId` - The resource ID of a Log Analytics workspace. Required and must be a valid workspace resource ID when `destinationType` is `CustomWorkspace`; otherwise optional.
  - `destinationType` - The type of the flow log destination. One of `CommunityWorkspace`, `CustomWorkspace`, `EnclaveWorkspace`.
  - `diagnosticSettingsName` - (Optional) The name of the diagnostic setting.
DESCRIPTION

  validation {
    condition = var.monitoring_settings == null || alltrue([
      for destination in concat(var.monitoring_settings.diagnosticDestinations, [var.monitoring_settings.flowLogDestination]) :
      contains(["CommunityWorkspace", "CustomWorkspace", "EnclaveWorkspace"], destination.destinationType)
    ])
    error_message = "The destinationType for diagnosticDestinations and flowLogDestination must be one of: `CommunityWorkspace`, `CustomWorkspace`, or `EnclaveWorkspace`."
  }

  validation {
    condition = var.monitoring_settings == null || alltrue([
      for destination in concat(var.monitoring_settings.diagnosticDestinations, [var.monitoring_settings.flowLogDestination]) :
      destination.destinationType == "CustomWorkspace" ? can(provider::azapi::parse_resource_id("Microsoft.OperationalInsights/workspaces", destination.customWorkspaceResourceId)) : true
    ])
    error_message = "When destinationType is `CustomWorkspace`, the corresponding customWorkspaceResourceId in diagnosticDestinations or flowLogDestination must be a valid Azure Log Analytics workspace resource ID."
  }
}

variable "dedicated_hubs" {
  type = map(object({
    name        = string
    designation = string
    location    = optional(string, null)
  }))

  default = {}
}
