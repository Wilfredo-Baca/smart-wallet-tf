provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "arg" {
  name     = "arg-${var.project}-${var.environment}"
  location = var.location

  tags = var.tags
}

resource "azurerm_resource_group" "rgbank" {
  name     = "rgbank-${var.project}-${var.environment}"
  location = var.location

  tags = var.tags
}