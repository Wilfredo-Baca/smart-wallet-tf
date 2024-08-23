# Service Plan for Web App UI (Basic B1)
resource "azurerm_service_plan" "app_service_plan_ui" {
  name                = "app-ui-${var.project}-${var.environment}"
  resource_group_name = azurerm_resource_group.arg.name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "B1"

  tags = var.tags
}

# Service Plan for Web App API (Basic B2)
resource "azurerm_service_plan" "app_service_plan_api" {
  name                = "app-api-${var.project}-${var.environment}"
  resource_group_name = azurerm_resource_group.arg.name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "B2"

  tags = var.tags
}

resource "azurerm_container_registry" "acr" {
  name                = "acr${var.project}${var.environment}"
  resource_group_name = azurerm_resource_group.arg.name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = true

  tags = var.tags
}

resource "azurerm_linux_web_app" "webapp_ui" {
  name                = "webapp-ui-${var.project}-${var.environment}"
  resource_group_name = azurerm_resource_group.arg.name
  location            = var.location
  service_plan_id     = azurerm_service_plan.app_service_plan_ui.id
  
  
  site_config {
    # linux_fx_version       = "DOCKER|${azurerm_container_registry.acr.login_server}/${var.project}/ui:latest" esta liena la puedo configurar en el portal de azure directamente?
    always_on              = true
    vnet_route_all_enabled = true
  }

  app_settings = {
    "DOCKER_REGISTRY_SERVER_URL"      = "https://${azurerm_container_registry.acr.login_server}"
    "DOCKER_REGISTRY_SERVER_USERNAME" = azurerm_container_registry.acr.admin_username
    "DOCKER_REGISTRY_SERVER_PASSWORD" = azurerm_container_registry.acr.admin_password
  }

  depends_on = [
    azurerm_service_plan.app_service_plan_ui,
    azurerm_container_registry.acr,
    azurerm_subnet.subnetweb
  ]

  tags = var.tags
}

resource "azurerm_app_service_virtual_network_swift_connection" "webapp_ui_vnet_swift_connection" {
  app_service_id = azurerm_linux_web_app.webapp_ui.id
  subnet_id      = azurerm_subnet.subnetweb.id
  depends_on     = [azurerm_linux_web_app.webapp_ui]
}

resource "azurerm_linux_web_app" "webapp_api" {
  name                = "webapp-api-${var.project}-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.arg.name
  service_plan_id     = azurerm_service_plan.app_service_plan_api.id

  site_config {
    # linux_fx_version       = "DOCKER|${azurerm_container_registry.acr.login_server}/${var.project}/api:latest"
    always_on              = true
    vnet_route_all_enabled = true
  }

  app_settings = {
    "DOCKER_REGISTRY_SERVER_URL"      = "https://${azurerm_container_registry.acr.login_server}"
    "DOCKER_REGISTRY_SERVER_USERNAME" = azurerm_container_registry.acr.admin_username
    "DOCKER_REGISTRY_SERVER_PASSWORD" = azurerm_container_registry.acr.admin_password
  }

  depends_on = [
    azurerm_service_plan.app_service_plan_api,
    azurerm_container_registry.acr,
    azurerm_subnet.subnetweb
  ]

  tags = var.tags
}

resource "azurerm_app_service_virtual_network_swift_connection" "webapp_api_vnet_swift_connection" {
  app_service_id = azurerm_linux_web_app.webapp_api.id
  subnet_id      = azurerm_subnet.subnetweb.id
  depends_on     = [azurerm_linux_web_app.webapp_api]
}
