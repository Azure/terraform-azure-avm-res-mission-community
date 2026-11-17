data "azapi_resource" "community" {
  resource_id            = var.parent_id
  type                   = "Microsoft.Mission/communities@2026-04-01"
  response_export_values = []
}
