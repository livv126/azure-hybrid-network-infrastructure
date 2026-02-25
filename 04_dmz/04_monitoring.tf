# App Gateway Diagnostics -> Log Analytics & Event Hub
resource "azurerm_monitor_diagnostic_setting" "agw_diag" {
  name                           = "agw-access-logs-${random_string.agw_diag_suffix.result}"
  target_resource_id             = azurerm_application_gateway.team02_agw_waf.id
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  eventhub_name                  = var.eventhub_name
  eventhub_authorization_rule_id = var.eventhub_auth_id

  enabled_log { category = "ApplicationGatewayAccessLog" }
  enabled_log { category = "ApplicationGatewayPerformanceLog" }
  enabled_log { category = "ApplicationGatewayFirewallLog" }
  enabled_metric { category = "AllMetrics" }

  depends_on = [azurerm_application_gateway.team02_agw_waf]
}