terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

variable "rgname" {
  type        = string
  description = "Resource Group Name"
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
  description = "DMZ VNet CIDR"
}

variable "username" {
  type        = string
  description = "VM Administrator username"
}

variable "ssh_public_key" {
  type        = string
  description = "SSH Public Key"
}

variable "waf_policy_id" {
  type        = string
  description = "WAF Policy ID from Policy module"
}

variable "lb_private_ip" {
  type        = string
  description = "App ILB Private IP for backend pool"
}

variable "app_vnet_cidr" {
  type        = string
  description = "App VNet CIDR"
}

variable "app_domain" {
  type        = string
  description = "Application custom domain"
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics Workspace ID"
}

variable "eventhub_auth_id" {
  type        = string
  description = "Event Hub Authorization Rule ID"
}

variable "eventhub_name" {
  type        = string
  description = "Event Hub Name"
}

resource "random_string" "agw_diag_suffix" {
  length  = 4
  special = false
  upper   = false
  numeric = true
}