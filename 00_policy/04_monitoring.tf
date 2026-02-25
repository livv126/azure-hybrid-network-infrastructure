# Central Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "law" {
  name                = "${var.prefix}-law-security-${random_string.common.result}"
  location            = var.location
  resource_group_name = var.rgname
  sku                 = "PerGB2018"
  retention_in_days   = 30
}