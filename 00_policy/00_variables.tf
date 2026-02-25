terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

# Random suffix for global uniqueness
resource "random_string" "common" {
  length  = 4       
  special = false   
  upper   = false   
  numeric = true    
}

variable "rgname" { 
  type        = string 
  description = "Target Resource Group Name"
}

variable "location" { 
  type        = string 
  description = "Primary region location"
}

variable "prefix" { 
  type        = string 
  description = "Resource name prefix"
}

variable "username" { 
  type        = string 
  description = "Default system administrator username"
}

# WAF Configuration Defaults
variable "waf_mode" {
  type    = string
  default = "Prevention"
}

variable "waf_rule_set_type" {
  type    = string
  default = "OWASP"
}

variable "waf_rule_set_version" {
  type    = string
  default = "3.2"
}