output "vnet_id" { value = azurerm_virtual_network.hub_vnet.id }
output "vnet_name" { value = azurerm_virtual_network.hub_vnet.name }
output "vnet_cidr" { value = var.vnet_cidr }

output "vpn_pubip" { value = azurerm_public_ip.vpn_pubip.ip_address }
output "bastion_public_ip" { value = azurerm_public_ip.hub_bat_pubip.ip_address }
output "vpn_public_ip" { value = azurerm_public_ip.vpn_pubip.ip_address }

output "eventhub_private_ip" {
  value = azurerm_private_endpoint.evh_pe.private_service_connection[0].private_ip_address
}

output "eventhub_connection_string" {
  value     = azurerm_eventhub_namespace_authorization_rule.logstash_auth.primary_connection_string
  sensitive = true
}

output "eventhub_auth_id" { value = azurerm_eventhub_namespace_authorization_rule.logstash_auth.id }
output "eventhub_name" { value = azurerm_eventhub.hub_evh.name }