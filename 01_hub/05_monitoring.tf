# Event Hub Namespace
resource "azurerm_eventhub_namespace" "hub_evhns" {
  name                = "ns-${var.prefix}-evhns-${random_string.hub_random.result}"
  location            = var.location
  resource_group_name = var.rgname
  sku                 = "Standard"
  capacity            = 1
}

# Event Hub Topic
resource "azurerm_eventhub" "hub_evh" {
  name              = "azure-logs"
  namespace_id      = azurerm_eventhub_namespace.hub_evhns.id
  partition_count   = 2
  message_retention = 1
}

# Authorization Rule
resource "azurerm_eventhub_namespace_authorization_rule" "logstash_auth" {
  name                = "listen-auth"
  namespace_name      = azurerm_eventhub_namespace.hub_evhns.name
  resource_group_name = var.rgname
  listen              = true
  send                = true
  manage              = false
}

# Private Endpoint for Event Hub
resource "azurerm_private_endpoint" "evh_pe" {
  name                = "${var.prefix}-evh-pe"
  location            = var.location
  resource_group_name = var.rgname
  subnet_id           = azurerm_subnet.hub_mgmt_snet.id

  private_service_connection {
    name                           = "evh-privatelink"
    private_connection_resource_id = azurerm_eventhub_namespace.hub_evhns.id
    is_manual_connection           = false
    subresource_names              = ["namespace"]
  }
}