mock_provider "azapi" {
  mock_data "azapi_resource" {
    defaults = {
      location = "centralus"
    }
  }
  mock_data "azapi_client_config" {
    defaults = {
      subscription_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000"
    }
  }
}

variables {
  name      = "unit-test-hub"
  parent_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Mission/communities/test-community"
}

run "omitted_location_uses_community_location" {
  command = apply

  assert {
    condition     = azapi_resource.this.location == "centralus"
    error_message = "The dedicated hub must inherit its parent Community's location when location is omitted."
  }

  assert {
    condition     = data.azapi_resource.community.resource_id == var.parent_id
    error_message = "The Community lookup must use the dedicated hub's parent ID."
  }
}

run "null_location_uses_community_location" {
  command = apply

  variables {
    location = null
  }

  assert {
    condition     = azapi_resource.this.location == "centralus"
    error_message = "The dedicated hub must inherit its parent Community's location when location is null."
  }
}

run "explicit_location_overrides_community_location" {
  command = apply

  variables {
    location = "westus2"
  }

  assert {
    condition     = azapi_resource.this.location == "westus2"
    error_message = "An explicit dedicated hub location must take precedence over the Community's location."
  }
}
