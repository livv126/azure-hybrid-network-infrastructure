output "vnet_id" { value = azurerm_virtual_network.app_vnet.id }
output "vnet_name" { value = azurerm_virtual_network.app_vnet.name }
output "vnet_cidr" { value = var.vnet_cidr }

output "lb_private_ip" {
  value       = azurerm_lb.app_lb.frontend_ip_configuration[0].private_ip_address
  description = "Internal Load Balancer IP for Application Gateway backend pool"
}

output "vmss_name" { value = azurerm_linux_virtual_machine_scale_set.app_vmss.name }
output "vmss_id" { value = azurerm_linux_virtual_machine_scale_set.app_vmss.id }