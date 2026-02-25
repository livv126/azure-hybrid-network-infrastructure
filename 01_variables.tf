variable "prodid" {
  type        = string
  default     = ""
  sensitive   = true
  description = "Azure Subscription ID"
}

# 공통 리소스 그룹
resource "azurerm_resource_group" "team02_rg" {
  name     = var.rgname
  location = local.region
}

variable "rgname" {
  type        = string
  default     = "05-team02-vpn-rg"     
  description = "Target Resource Group Name"
}

variable "username" {
  type        = string
  default     = "adminuser"
  description = "Common administrator username for VMs"
}

variable "db_password" {
  type        = string
  default     = ""
  description = "Database administrator password"
  sensitive   = true 
}

variable "app_domain" {
  type        = string
  default     = ""
  description = "Application custom domain"
}

variable "prefix" {
  type        = string
  default     = "team02"
  description = "Global resource naming prefix"
}

locals {
  # Common Tags & Naming
  region  = "koreacentral"
  project = "team02"

  # Private DNS Zone Name Definition
  mysql_dns_name = "privatelink.mysql.database.azure.com"

  # =======================================================
  # [VPN Configuration] On-Premises Connection Details
  # =======================================================
  onprem_public_ip = ""       
  onprem_cidr      = ["192.168.20.0/24"] 
  vpn_shared_key   = ""

  # IPSec/IKE Policy (Recommended settings)
  vpn_policy = {
    dh_group         = "DHGroup2" 
    ike_encryption   = "AES256"    
    ike_integrity    = "SHA256"    
    ipsec_encryption = "AES256"    
    ipsec_integrity  = "SHA256"    
    pfs_group        = "PFS2"
    sa_lifetime      = 3600        
  }

  # Network CIDR Planning
  hub_cidr  = "10.10.0.0/16"
  app_cidr  = "10.20.0.0/16"
  data_cidr = "10.30.0.0/16"
  dmz_cidr  = "10.40.0.0/16"

  data_subnet_cidr = "10.30.1.0/24"
  
  # Pre-calculated Internal Load Balancer IP
  app_lb_private_ip = cidrhost(local.app_cidr, 4)
}
