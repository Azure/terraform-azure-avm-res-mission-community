// TODO: Implement tests
mock_provider "azapi" {}
mock_provider "modtm" {}
mock_provider "random" {}

variables {
  location       = "eastus"
  name           = "unit-test-cmt-eus-01"
  parent_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/my-test-rg"
  address_spaces = ["10.0.0.0/16"]
}

run "valid_maintenance_configuration_off" {
  command = plan

  variables {
    maintenance_mode_configuration = {
      mode          = "Off"
      justification = "Off"
      principals    = []
    }
  }
}

run "valid_maintenance_configuration_on" {
  command = plan

  variables {
    maintenance_mode_configuration = {
      mode          = "On"
      justification = "Governance"
      principals = [
        {
          id   = "00000000-0000-0000-0000-000000000000"
          type = "User"
        }
      ]
    }
  }
}

run "invalid_principal_id" {
  command = plan

  variables {
    maintenance_mode_configuration = {
      mode          = "On"
      justification = "Networking"
      principals = [
        {
          id   = "invalid-id"
          type = "User"
        }
      ]
    }
  }

  expect_failures = [var.maintenance_mode_configuration]
}

run "invalid_principal_type" {
  command = plan

  variables {
    maintenance_mode_configuration = {
      mode          = "On"
      justification = "Networking"
      principals = [
        {
          id   = "00000000-0000-0000-0000-000000000000"
          type = "InvalidType"
        }
      ]
    }
  }

  expect_failures = [var.maintenance_mode_configuration]
}

run "invalid_justification" {
  command = plan

  variables {
    maintenance_mode_configuration = {
      mode          = "On"
      justification = "InvalidJustification"
      principals = [
        {
          id   = "00000000-0000-0000-0000-000000000000"
          type = "User"
        }
      ]
    }
  }

  expect_failures = [var.maintenance_mode_configuration]
}
