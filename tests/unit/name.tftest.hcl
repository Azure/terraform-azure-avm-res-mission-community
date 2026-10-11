mock_provider "azapi" {}
mock_provider "modtm" {}
mock_provider "random" {}

variables {
  location       = "eastus"
  name           = "unit-test-cmt-eus-01"
  parent_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/my-test-rg"
  address_spaces = ["10.0.0.0/16"]
}

run "valid_name" {
  command = plan

  variables {
    name = "unit-TEST-cmt-eastus-01"
  }
}

run "invalid_name_starts_with_number" {
  command = plan

  variables {
    name = "1unit-test-cmt-eastus-01"
  }

  expect_failures = [var.name]
}

run "invalid_name_ends_with_hyphen" {
  command = plan

  variables {
    name = "unit-test-cmt-eastus-01-"
  }

  expect_failures = [var.name]
}

run "invalid_name_too_long" {
  command = plan

  variables {
    name = "unit-test-cmt-eastus-01-unit-test-cmt-eastus-01-unit-test-cmt-eastus-01"
  }

  expect_failures = [var.name]
}

run "invalid_name_too_short" {
  command = plan

  variables {
    name = "ut"
  }

  expect_failures = [var.name]
}
