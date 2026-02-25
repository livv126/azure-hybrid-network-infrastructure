# DMZ VNet
resource "azurerm_virtual_network" "dmz_vnet" {
  name                = "${var.prefix}-vnet-dmz"
  location            = var.location
  resource_group_name = var.rgname
  address_space       = [var.vnet_cidr] 
}

# Application Gateway Subnet
resource "azurerm_subnet" "snet_agw" {
  name                 = "${var.prefix}-snet-agw"
  resource_group_name  = var.rgname
  virtual_network_name = azurerm_virtual_network.dmz_vnet.name
  address_prefixes     = [cidrsubnet(var.vnet_cidr, 8, 1)]
}

# Public IP for App Gateway
resource "azurerm_public_ip" "pip_agw" {
  name                = "${var.prefix}-agw-pip"
  location            = var.location
  resource_group_name = var.rgname
  allocation_method   = "Static"
  sku                 = "Standard" 
  domain_name_label   = "dmz-agw-web-${random_string.agw_diag_suffix.result}" 
}

# Route Table for DMZ
resource "azurerm_route_table" "dmz_rt" {
  name                = "${var.prefix}-rt-dmz"
  location            = var.location
  resource_group_name = var.rgname
}

resource "azurerm_subnet_route_table_association" "dmz_assoc" {
  subnet_id      = azurerm_subnet.snet_agw.id
  route_table_id = azurerm_route_table.dmz_rt.id
}