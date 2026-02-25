# Hub VNet & Subnets
resource "azurerm_virtual_network" "hub_vnet" {
  name                = "${var.prefix}-hub-vnet"
  location            = var.location
  resource_group_name = var.rgname
  address_space       = [var.vnet_cidr]  
}

resource "azurerm_subnet" "hub_gateway_snet" {
  name                 = "GatewaySubnet"
  resource_group_name  = var.rgname
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = [cidrsubnet(var.vnet_cidr, 8, 1)]
}

resource "azurerm_subnet" "hub_bat_snet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.rgname
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = [cidrsubnet(var.vnet_cidr, 8, 2)]
}

resource "azurerm_subnet" "hub_mgmt_snet" {
  name                 = "${var.prefix}-snet-mgmt"
  resource_group_name  = var.rgname
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = [cidrsubnet(var.vnet_cidr, 8, 3)] 
}

# Public IPs
resource "azurerm_public_ip" "vpn_pubip" {
  name                = "${var.prefix}-vpn-pubip"
  location            = var.location
  resource_group_name = var.rgname
  allocation_method   = "Static"
  sku                 = "Standard"
  ip_version          = "IPv4"
}

resource "azurerm_public_ip" "hub_bat_pubip" {
  name                = "${var.prefix}-bastion-pubip"
  location            = var.location
  resource_group_name = var.rgname
  allocation_method   = "Static"
  sku                 = "Standard"
}