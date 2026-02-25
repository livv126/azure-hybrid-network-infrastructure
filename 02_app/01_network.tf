# App VNet
resource "azurerm_virtual_network" "app_vnet" {
  name                = "${var.prefix}-app-vnet"
  resource_group_name = var.rgname
  location            = var.location
  address_space       = [var.vnet_cidr]
}

# App Subnet
resource "azurerm_subnet" "app_snet" {
  name                 = "${var.prefix}-snet-app"
  resource_group_name  = var.rgname
  virtual_network_name = azurerm_virtual_network.app_vnet.name
  address_prefixes     = [var.vnet_cidr]
}

# Route Table for On-premise Routing
resource "azurerm_route_table" "app_rt" {
  name                = "${var.prefix}-app-rt"
  location            = var.location
  resource_group_name = var.rgname
}

resource "azurerm_route" "to_onprem" {
  name                   = "to-onprem-db"
  resource_group_name    = var.rgname
  route_table_name       = azurerm_route_table.app_rt.name
  address_prefix         = "192.168.20.0/24" 
  next_hop_type          = "VirtualNetworkGateway"
}

resource "azurerm_subnet_route_table_association" "app_rt_assoc" {
  subnet_id      = azurerm_subnet.app_snet.id
  route_table_id = azurerm_route_table.app_rt.id
}

# NAT Gateway for Outbound Internet Access
resource "azurerm_public_ip" "nat_pip" {
  name                = "${var.prefix}-nat-pip"
  location            = var.location
  resource_group_name = var.rgname
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_nat_gateway" "app_nat" {
  name                    = "${var.prefix}-natgw"
  location                = var.location
  resource_group_name     = var.rgname
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
}

resource "azurerm_nat_gateway_public_ip_association" "nat_pip_assoc" {
  nat_gateway_id       = azurerm_nat_gateway.app_nat.id
  public_ip_address_id = azurerm_public_ip.nat_pip.id
}

resource "azurerm_subnet_nat_gateway_association" "snet_nat_assoc" {
  subnet_id      = azurerm_subnet.app_snet.id
  nat_gateway_id = azurerm_nat_gateway.app_nat.id
}