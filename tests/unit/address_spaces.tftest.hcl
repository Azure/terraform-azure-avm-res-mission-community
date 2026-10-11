// Unit tests for the address_spaces variable validation
mock_provider "azapi" {}
mock_provider "modtm" {}
mock_provider "random" {}

variables {
  location  = "eastus"
  name      = "unit-test-cmt-eus-01"
  parent_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/my-test-rg"
  maintenance_mode_configuration = {
    mode       = "Off"
    principals = []
  }
}

run "valid_cidr" {
  command = plan

  variables {
    address_spaces = ["10.0.0.0/16", "10.1.0.0/16"]
  }
}

run "invalid_cidr_rejected" {
  command = plan

  variables {
    address_spaces = ["10.0.0.0/16", "invalid-cidr"]
  }

  expect_failures = [var.address_spaces]
}

run "reserved_cidr_rejected" {
  command = plan

  variables {
    address_spaces = ["10.0.0.0/16", "192.168.0.0/16"]
  }

  expect_failures = [var.address_spaces]
}

run "cidr_more_than_16_rejected" {
  command = plan

  variables {
    address_spaces = ["10.0.0.0/16", "192.168.0.0/17"]
  }

  expect_failures = [var.address_spaces]
}
