resource "random_string" "lb_diag_suffix" {
  length  = 4
  special = false
  upper   = false
  numeric = true
}

# ILB Diagnostics
resource "azurerm_monitor_diagnostic_setting" "lb_diag" {
  name                       = "lb-health-logs-${random_string.lb_diag_suffix.result}"
  target_resource_id         = azurerm_lb.app_lb.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_metric {
    category = "AllMetrics"
  }
  depends_on = [azurerm_lb.app_lb]
}