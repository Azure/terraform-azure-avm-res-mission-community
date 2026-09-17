// Unit tests to validate various approval settings
mock_provider "azapi" {}
mock_provider "modtm" {}
mock_provider "random" {}

variables {
  location       = "eastus"
  name           = "unit-test-cmt-eus-01"
  parent_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/my-test-rg"
  address_spaces = ["10.0.0.0/16"]
}

run "valid_approval_settings" {
  command = plan

  variables {
    approval_settings = {
      communityEndpointUpdate = {
        approvalPolicy     = "Required"
        mandatoryApprovers = [{ approverEntraId = "approver-1" }]
      }
      communityMaintenanceMode = {
        approvalPolicy           = "Required"
        minimumApproversRequired = 2
        mandatoryApprovers       = [{ approverEntraId = "approver-1" }, { approverEntraId = "approver-2" }]
      }
      connectionCreation = {
        approvalPolicy     = "Required"
        mandatoryApprovers = [{ approverEntraId = "approver-1" }, { approverEntraId = "approver-2" }]
      }
      connectionUpdate = {
        approvalPolicy = "NotRequired"
      }
      enclaveCreation = {
        approvalPolicy           = "Required"
        minimumApproversRequired = 0
        mandatoryApprovers       = [{ approverEntraId = "approver-1" }]
      }
      enclaveEndpointUpdate = {
        approvalPolicy     = "Required"
        mandatoryApprovers = [{ approverEntraId = "approver-1" }]
      }
      enclaveMaintenanceMode = {
        approvalPolicy     = "Required"
        mandatoryApprovers = [{ approverEntraId = "approver-1" }]
      }
    }
  }
}

run "invalid_approval_setting_key" {
  command = plan

  variables {
    approval_settings = {
      invalidKey = {
        approvalPolicy = "Required"
        approvers      = [{ approverEntraId = "approver-1" }]
      }
    }
  }

  expect_failures = [var.approval_settings]
}
