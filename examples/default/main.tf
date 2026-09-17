terraform {
  required_version = "~> 1.5"

  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.12"
    }
    modtm = {
      source  = "azure/modtm"
      version = "~> 0.3"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/avm-utl-naming/azure"
  version = "~> 0.2"

  custom_override_file = "${path.module}/../naming-overrides.json"
  instance             = 1
  instance_format      = "%02d"
  naming_template_variables = {
    environment = "test"
    location    = var.location
  }
  naming_templates = {
    name = "$${prefix[0]}$${separator}$${environment}$${separator}$${slug}$${separator}$${location}$${separator}$${instance}"
  }
  prefix        = ["avmcmt"]
  unique_length = 0
}

# This is required for resource modules
resource "azapi_resource" "rg" {
  location = var.location # Only limited regions are supported, so hardcoding this
  name     = module.naming.names_by_azure_type["Microsoft.Resources/resourceGroups"].resource_group.name
  type     = "Microsoft.Resources/resourceGroups@2025-04-01"
}

# This is the module call
module "test" {
  source = "../../"

  address_spaces   = ["10.0.0.0/16"]
  location         = azapi_resource.rg.location
  name             = module.naming.names_by_azure_type["Microsoft.Mission/communities"].community.name
  parent_id        = azapi_resource.rg.id
  enable_telemetry = var.enable_telemetry # see variables.tf
}
