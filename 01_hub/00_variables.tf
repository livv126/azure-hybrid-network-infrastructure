terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

resource "random_string" "hub_random" {
  length  = 5
  special = false
  upper   = false
  numeric = true
}

variable "rgname" { type = string }
variable "location" { type = string }
variable "prefix" { type = string }
variable "vnet_cidr" { type = string }
variable "username" { type = string }
variable "ssh_public_key" { type = string }
variable "ssh_private_key" { type = string }
variable "log_analytics_workspace_id" { type = string }
variable "onprem_public_ip" { type = string }
variable "onprem_cidr" { type = list(string) }
variable "vpn_shared_key" { type = string }
variable "vpn_policy" { type = map(any) }