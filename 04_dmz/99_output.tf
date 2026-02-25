output "vnet_id" { value = azurerm_virtual_network.dmz_vnet.id }
output "vnet_name" { value = azurerm_virtual_network.dmz_vnet.name }
output "vnet_cidr" { value = var.vnet_cidr }

output "agw_pip_id" {
  value       = azurerm_public_ip.pip_agw.id
  description = "App Gateway Public IP Resource ID"
}

output "appgw_public_ip" {
  value       = azurerm_public_ip.pip_agw.ip_address
  description = "Frontend Public IP of the Application Gateway"
}