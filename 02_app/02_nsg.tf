# App Subnet NSG
resource "azurerm_network_security_group" "app_nsg" {
  name                = "${var.prefix}-app-nsg"
  location            = var.location
  resource_group_name = var.rgname
}

resource "azurerm_subnet_network_security_group_association" "app_nsg_assoc" {
  subnet_id                 = azurerm_subnet.app_snet.id
  network_security_group_id = azurerm_network_security_group.app_nsg.id
}

# NSG Rules
resource "azurerm_network_security_rule" "allow_http_from_dmz" {
  name                        = "Allow-HTTP-From-DMZ"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = var.dmz_vnet_cidr
  destination_address_prefix  = "*"
  resource_group_name         = var.rgname
  network_security_group_name = azurerm_network_security_group.app_nsg.name
}

resource "azurerm_network_security_rule" "allow_ssh_from_hub" {
  name                        = "Allow-SSH-From-Hub"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = var.hub_vnet_cidr
  destination_address_prefix  = "*"
  resource_group_name         = var.rgname
  network_security_group_name = azurerm_network_security_group.app_nsg.name
}

resource "azurerm_network_security_rule" "allow_db_outbound" {
  name                        = "Allow-DB-OnPrem"
  priority                    = 120
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3306"          
  source_address_prefix       = "*"
  destination_address_prefix  = "192.168.20.0/24" 
  resource_group_name         = var.rgname
  network_security_group_name = azurerm_network_security_group.app_nsg.name
}

resource "azurerm_network_security_rule" "allow_internet_outbound" {
  name                        = "Allow-Internet-Outbound"
  priority                    = 130
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*" 
  source_address_prefix       = "*"
  destination_address_prefix  = "Internet" 
  resource_group_name         = var.rgname
  network_security_group_name = azurerm_network_security_group.app_nsg.name
}

resource "azurerm_network_security_rule" "allow_http_from_onprem" {
  name                        = "Allow-HTTP-From-OnPrem"
  priority                    = 140
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "192.168.20.0/24" 
  destination_address_prefix  = "*"
  resource_group_name         = var.rgname
  network_security_group_name = azurerm_network_security_group.app_nsg.name
}