data "azapi_resource" "community" {
  type                   = "Microsoft.Mission/communities@2026-04-01"
  resource_id            = var.parent_id
  response_export_values = []
}