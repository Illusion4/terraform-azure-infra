terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.75.0"
    }
  }
  required_version = ">= 1.9.0"
}

provider "azurerm" {
  features {}

  skip_provider_registration = true
}

terraform {
  backend "azurerm" {
    # Configuration is provided by the pipeline
    # Don't hardcode values here when using the task
  }
}
