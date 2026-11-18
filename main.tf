module "avm_interfaces" {
  source  = "Azure/avm-utl-interfaces/azure"
  version = "0.9.0"

  location           = var.location
  enable_telemetry   = var.enable_telemetry
  managed_identities = var.managed_identities
}

resource "azapi_resource" "this" {
  location  = var.location
  name      = var.name
  parent_id = var.parent_id
  # LATER: Consider making this a parameter to enable opting into newer or older API versions
  type = "Microsoft.Mission/communities@2026-04-01"
  body = {
    properties = {
      addressSpaces                = var.address_spaces
      approvalSettings             = var.approval_settings
      communityRoleAssignments     = var.community_role_assignments
      dnsServers                   = var.dns_servers
      firewallSku                  = var.firewall_sku
      governedServiceList          = var.governed_service_list
      maintenanceModeConfiguration = var.maintenance_mode_configuration
      policyOverride               = var.policy_override
      monitoringSettings           = var.monitoring_settings
    }
  }
  tags = var.tags

  dynamic "identity" {
    for_each = module.avm_interfaces.managed_identities_azapi != null ? [module.avm_interfaces.managed_identities_azapi] : []
    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }
}

resource "azapi_resource" "role_assignments" {
  for_each = var.role_assignments

  parent_id = azapi_resource.this.id
  type      = "Microsoft.Authorization/roleAssignments@2022-04-01"
  body = {
    properties = {
      principalId                        = each.value.principal_id
      principalType                      = each.value.principal_type
      roleDefinitionId                   = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.role_definition_id_or_name : null
      condition                          = each.value.condition
      conditionVersion                   = each.value.condition_version
      delegatedManagedIdentityResourceId = each.value.delegated_managed_identity_resource_id
      description                        = each.value.description
    }
  }
}

module "dedicated_hubs" {
  source   = "./modules/dedicated_hub"
  for_each = var.dedicated_hubs

  name             = each.value.name
  parent_id        = azapi_resource.this.id
  designation      = each.value.designation
  enable_telemetry = var.enable_telemetry
  location         = each.value.location != null ? each.value.location : azapi_resource.this.location
  tags             = var.tags
}

# TODO: Add transitHubs
# TODO: Add communityEndpoints
