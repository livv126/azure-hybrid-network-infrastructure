terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

variable "rgname" { 
  type        = string 
  description = "Target Resource Group Name"
}

variable "location" { 
  type        = string 
  description = "Target Region Location"
}

variable "prefix" { 
  type        = string 
  description = "Resource name prefix"
}

variable "vnet_cidr" { 
  type        = string 
  description = "Application VNet CIDR address space"
}

variable "username" { 
  type        = string 
  description = "VM Administrator username"
}

variable "ssh_public_key" { 
  type        = string 
  description = "SSH public key for VM authentication"
}

variable "vm_count" {
  type        = number
  default     = 2
  description = "Number of VM instances in Scale Set"
}

variable "dmz_vnet_cidr" { 
  type        = string 
  description = "DMZ VNet CIDR for NSG rules"
}

variable "hub_vnet_cidr" { 
  type        = string 
  description = "Hub VNet CIDR for NSG rules"
}

variable "lb_private_ip" { 
  type        = string 
  description = "Pre-calculated Internal Load Balancer Private IP"
}

variable "log_analytics_workspace_id" { 
  type        = string 
  description = "Log Analytics Workspace ID for monitoring"
}

variable "domain_name" { 
  type        = string 
  description = "Custom domain name for the application"
}

variable "onprem_cidr" { 
  type        = list(string) 
  description = "On-premises CIDR block for NSG rules"
}