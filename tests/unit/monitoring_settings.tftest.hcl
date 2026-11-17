mock_provider "azapi" {}
mock_provider "modtm" {}
mock_provider "random" {}

variables {
  location       = "eastus"
  name           = "unit-test-cmt-eus-01"
  parent_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/my-test-rg"
  address_spaces = ["10.0.0.0/16"]
}

run "valid_monitoring_settings" {
  command = plan

  variables {
    monitoring_settings = {
      diagnosticDestinations = [
        {
          destinationType = "CommunityWorkspace"
        },
        {
          customWorkspaceResourceId = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/my-test-rg/providers/Microsoft.OperationalInsights/workspaces/workspace-name"
          destinationType           = "CustomWorkspace"
          diagnosticSettingsName    = "custom-settings"
        }
      ]
      flowLogDestination = {
        customWorkspaceResourceId = null
        destinationType           = "EnclaveWorkspace"
        diagnosticSettingsName    = "enclave-ws-setting"
      }
    }
  }
}

run "valid_custom_flow_log_workspace" {
  command = plan

  variables {
    monitoring_settings = {
      diagnosticDestinations = []
      flowLogDestination = {
        destinationType           = "CustomWorkspace"
        customWorkspaceResourceId = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/my-test-rg/providers/Microsoft.OperationalInsights/workspaces/flow-logs"
      }
    }
  }
}

run "missing_custom_diagnostic_workspace" {
  command = plan

  variables {
    monitoring_settings = {
      diagnosticDestinations = [
        { destinationType = "CommunityWorkspace" },
        { destinationType = "CustomWorkspace" }
      ]
      flowLogDestination = { destinationType = "CommunityWorkspace" }
    }
  }

  expect_failures = [var.monitoring_settings]
}

run "null_custom_flow_log_workspace" {
  command = plan

  variables {
    monitoring_settings = {
      diagnosticDestinations = []
      flowLogDestination = {
        destinationType           = "CustomWorkspace"
        customWorkspaceResourceId = null
      }
    }
  }

  expect_failures = [var.monitoring_settings]
}

run "empty_custom_diagnostic_workspace" {
  command = plan

  variables {
    monitoring_settings = {
      diagnosticDestinations = [{
        destinationType           = "CustomWorkspace"
        customWorkspaceResourceId = ""
      }]
      flowLogDestination = { destinationType = "CommunityWorkspace" }
    }
  }

  expect_failures = [var.monitoring_settings]
}

run "empty_custom_flow_log_workspace" {
  command = plan

  variables {
    monitoring_settings = {
      diagnosticDestinations = []
      flowLogDestination = {
        destinationType           = "CustomWorkspace"
        customWorkspaceResourceId = ""
      }
    }
  }

  expect_failures = [var.monitoring_settings]
}

run "wrong_custom_diagnostic_resource_type" {
  command = plan

  variables {
    monitoring_settings = {
      diagnosticDestinations = [{
        destinationType           = "CustomWorkspace"
        customWorkspaceResourceId = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/my-test-rg/providers/Microsoft.Storage/storageAccounts/not-a-workspace"
      }]
      flowLogDestination = { destinationType = "CommunityWorkspace" }
    }
  }

  expect_failures = [var.monitoring_settings]
}

run "malformed_custom_flow_log_workspace" {
  command = plan

  variables {
    monitoring_settings = {
      diagnosticDestinations = []
      flowLogDestination = {
        destinationType           = "CustomWorkspace"
        customWorkspaceResourceId = "not-a-resource-id"
      }
    }
  }

  expect_failures = [var.monitoring_settings]
}

run "null_monitoring_settings" {
  command = plan

  variables {
    monitoring_settings = null
  }
}
