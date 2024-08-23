resource "azurerm_mssql_server" "sql_server" {
  name = "sqlserver-${var.project}-${var.environment}"
  resource_group_name = azurerm_resource_group.arg.name
  location = var.location
  version = "12.0"
  administrator_login = var.administrator-login
  administrator_login_password = var.administrator-login-password
  
  tags = var.tags
}

resource "azurerm_mssql_database" "sql_database" {
  name = "${var.project}.db"
  server_id = azurerm_mssql_server.sql_server.id
  sku_name = "S0"

  tags = var.tags
}

resource "azurerm_private_endpoint" "sql_priv_endpoint" {
  name = "sql-pe-${var.project}-${var.environment}"
  location = var.location
  resource_group_name = azurerm_resource_group.arg.name
  subnet_id = azurerm_subnet.subnetdb.id

  private_service_connection {
    name = "sql-pe-conn-${var.project}-${var.environment}"
    private_connection_resource_id = azurerm_mssql_server.sql_server.id
    subresource_names = ["sqlServer"]
    is_manual_connection = false
  }

  tags = var.tags

}

resource "azurerm_private_dns_zone" "priv_dns_zone" {
  name = "privatelink.database.windows.net"
  resource_group_name = azurerm_resource_group.arg.name

  tags = var.tags
}

resource "azurerm_private_dns_a_record" "priv_dns_a_record" {
  name = "priv-dns-record-${var.project}-${var.environment}"
  zone_name = azurerm_private_dns_zone.priv_dns_zone.name
  resource_group_name = azurerm_resource_group.arg.name
  ttl = 300
  records = [azurerm_private_endpoint.sql_priv_endpoint.private_service_connection.0.private_ip_address]

  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "priv_dns_vnet_link" {
  name = "priv-dns-vnet-link-${var.project}-${var.environment}"
  resource_group_name = azurerm_resource_group.arg.name
  private_dns_zone_name = azurerm_private_dns_zone.priv_dns_zone.name
  virtual_network_id = azurerm_virtual_network.vnet.id

  tags = var.tags
}

resource "azurerm_mssql_firewall_rule" "allow_my_ip" {
  name = "allow_my_ip${var.project}-${var.environment}"
  # resource_group_name = azurerm_mssql_server.sql_server.resource_group_name
  server_id = azurerm_mssql_server.sql_server.id
  # server_name = azurerm_mssql_server.sql_server.name
  start_ip_address = var.my-ip
  end_ip_address = var.my-ip
}