module "avm_interfaces" {
  source  = "Azure/avm-utl-interfaces/azure"
  version = "0.7.0"

  managed_identities = var.managed_identities
}

resource "azapi_resource" "this" {
  location  = var.location
  name      = var.name
  parent_id = var.parent_id
  # LATER: Consider making this a parameter to enable opting into newer or older API versions
  type = "Microsoft.Mission/communities@2026-03-01-preview"
  body = {
    properties = {
      addressSpaces                = var.address_spaces
      approvalSettings             = var.approval_settings
      dnsServers                   = var.dns_servers
      firewallSku                  = var.firewall_sku
      governedServiceList          = var.governed_service_list
      maintenanceModeConfiguration = var.maintenance_mode_configuration
      policyOverride               = var.policy_override

      // TODO: Add monitoringSettings and communityRoleAssignments
      // TODO: Add dedicatedHubs
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

# TODO: required AVM resources interfaces
# resource "azurerm_role_assignment" "this" {
#   for_each = var.role_assignments

#   principal_id                           = each.value.principal_id
#   scope                                  = azurerm_resource_group.TODO.id # TODO: Replace this dummy resource azurerm_resource_group.TODO with your module resource
#   condition                              = each.value.condition
#   condition_version                      = each.value.condition_version
#   delegated_managed_identity_resource_id = each.value.delegated_managed_identity_resource_id
#   principal_type                         = each.value.principal_type
#   role_definition_id                     = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.role_definition_id_or_name : null
#   role_definition_name                   = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? null : each.value.role_definition_id_or_name
#   skip_service_principal_aad_check       = each.value.skip_service_principal_aad_check
# }
