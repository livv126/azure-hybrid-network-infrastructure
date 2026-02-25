output "resource_group_name" { value = var.rgname }
output "location" { value = var.location }
output "log_analytics_id" { value = azurerm_log_analytics_workspace.law.id }
output "rg_name" { value = var.rgname }

output "ssh_private_key" {
  value       = tls_private_key.global_key.private_key_pem
  sensitive   = true
  description = "SSH private key for Bastion initialization"
}

output "ssh_public_key" {
  value       = tls_private_key.global_key.public_key_openssh
  sensitive   = true
  description = "SSH public key for VM authentication"
}

output "waf_id_primary" {
  value       = azurerm_web_application_firewall_policy.waf_primary.id
  description = "Primary WAF Policy ID for Application Gateway"
}