# Management Subnet NSG
resource "azurerm_network_security_group" "hub_mgmt_nsg" {
  name                = "${var.prefix}-mgmt-nsg"
  location            = var.location
  resource_group_name = var.rgname
}

resource "azurerm_subnet_network_security_group_association" "mgmt_snet_assoc" {
  subnet_id                 = azurerm_subnet.hub_mgmt_snet.id
  network_security_group_id = azurerm_network_security_group.hub_mgmt_nsg.id
}

# NSG Rules
resource "azurerm_network_security_rule" "ssh_from_bastion" {
  name                        = "Allow-SSH-From-Bastion-PaaS"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = azurerm_subnet.hub_bat_snet.address_prefixes[0] 
  destination_address_prefix  = "*"
  resource_group_name         = var.rgname
  network_security_group_name = azurerm_network_security_group.hub_mgmt_nsg.name
}

resource "azurerm_network_security_rule" "ssh_from_vpn" {
  name                        = "Allow-SSH-From-VPN"
  priority                    = 110 
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefixes     = var.onprem_cidr
  destination_address_prefix  = "*"
  resource_group_name         = var.rgname
  network_security_group_name = azurerm_network_security_group.hub_mgmt_nsg.name
}

resource "azurerm_network_security_rule" "allow_eventhub_from_onprem" {
  name                        = "Allow-EventHub-From-OnPrem"
  priority                    = 120 
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["5671", "5672", "443"]
  source_address_prefixes     = var.onprem_cidr
  destination_address_prefix  = azurerm_subnet.hub_mgmt_snet.address_prefixes[0]
  resource_group_name         = var.rgname
  network_security_group_name = azurerm_network_security_group.hub_mgmt_nsg.name
}