output "SERVICE_INFO" {
  description = "Core Connection Info for the Infrastructure"
  value = {
    "Web_Frontend"  = module.dmz.appgw_public_ip
    "Bastion_IP"    = module.hub.bastion_public_ip
    "VPN_Gateway"   = module.hub.vpn_public_ip
    "Web_VMSS_Name" = module.app.vmss_name
    "LB_IP"         = module.app.lb_private_ip
  }
}

output "SSH_COMMANDS" {
  description = "SSH Commands for Administrator Access"
  value = <<EOT
  
  [1] Web Server Access (via Bastion)
  ssh -J ${var.username}@${module.hub.bastion_public_ip} ${var.username}@<VMSS_INSTANCE_PRIVATE_IP>
  
  EOT
}