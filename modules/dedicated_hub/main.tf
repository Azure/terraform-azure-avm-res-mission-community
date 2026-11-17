resource "azapi_resource" "this" {
  location  = var.location != null ? var.location : data.azapi_resource.community.location
  name      = var.name
  parent_id = var.parent_id
  type      = "Microsoft.Mission/communities/dedicatedHubs@2026-04-01"
  body = {
    properties = {
      designation = var.designation
    }
  }
  # HACK: 2026-11-17: azapi 2.13 does not have this version of the API
  schema_validation_enabled = false
  tags                      = var.tags
}
