# Fetch current Azure client config for Key Vault access policies
data "azurerm_client_config" "current" {}

# Core Key Vault
resource "azurerm_key_vault" "kv" {
  name                        = "${var.prefix}-kv-core-${random_string.common.result}"
  location                    = var.location
  resource_group_name         = var.rgname
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"

  access_policy {
    tenant_id          = data.azurerm_client_config.current.tenant_id
    object_id          = data.azurerm_client_config.current.object_id
    secret_permissions = [
      "Get", "List", "Set", "Delete", "Recover", "Backup", "Restore", "Purge"
    ]
  }
}

# Key Vault Diagnostics
resource "azurerm_monitor_diagnostic_setting" "kv_diag" {
  name                       = "kv-audit-logs-${random_string.common.result}"
  target_resource_id         = azurerm_key_vault.kv.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  enabled_log {
    category = "AuditEvent"
  }
}

# Global SSH Key Pair Generation
resource "tls_private_key" "global_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_key_vault_secret" "ssh_private_key" {
  name         = "ssh-private-key-${random_string.common.result}"
  value        = tls_private_key.global_key.private_key_pem
  key_vault_id = azurerm_key_vault.kv.id
  content_type = "application/x-pem-file"
  depends_on   = [azurerm_key_vault.kv]
}

resource "azurerm_key_vault_secret" "ssh_public_key" {
  name         = "ssh-public-key-${random_string.common.result}"
  value        = tls_private_key.global_key.public_key_openssh
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_key_vault.kv]
}

# Primary WAF Policy
resource "azurerm_web_application_firewall_policy" "waf_primary" {
  name                = "${var.prefix}-waf-primary"
  resource_group_name = var.rgname
  location            = var.location 

  policy_settings {
    enabled                     = true
    mode                        = var.waf_mode 
    request_body_check          = true
    max_request_body_size_in_kb = 128
    file_upload_limit_in_mb     = 100
  }

  managed_rules {
    managed_rule_set {
      type    = var.waf_rule_set_type    
      version = var.waf_rule_set_version 
    }
  }
}