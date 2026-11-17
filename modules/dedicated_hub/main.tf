resource "azapi_resource" "this" {
  type = "Microsoft.Mission/communities/dedicatedHubs@2026-04-01"

  # HACK: 2026-11-17: azapi 2.13 does not have this version of the API
  schema_validation_enabled = false

  name      = var.name
  location  = var.location != null ? var.location : data.azapi_resource.community.location
  parent_id = var.parent_id

  body = {
    properties = {
      designation = var.designation
    }
  }

  tags = var.tags
}
