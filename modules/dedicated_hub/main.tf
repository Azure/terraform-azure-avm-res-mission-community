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
  tags = var.tags

  timeouts {
    # Hub contain a Firewall which can easily take more than 30 minutes to deploy
    create = "1h"
    update = "1h"
    delete = "45m"
  }
}
