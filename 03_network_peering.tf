# ==============================================================================
# Hub <-> DMZ Peering
# ==============================================================================
resource "azurerm_virtual_network_peering" "hub_to_dmz" {
  name                         = "peer-hub-to-dmz"
  resource_group_name          = var.rgname
  virtual_network_name         = module.hub.vnet_name
  remote_virtual_network_id    = module.dmz.vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  depends_on                   = [azurerm_resource_group.team02_rg]
}

resource "azurerm_virtual_network_peering" "dmz_to_hub" {
  name                         = "peer-dmz-to-hub"
  resource_group_name          = var.rgname
  virtual_network_name         = module.dmz.vnet_name
  remote_virtual_network_id    = module.hub.vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  use_remote_gateways          = false
  depends_on                   = [azurerm_resource_group.team02_rg]
}

# ==============================================================================
# Hub <-> App Peering
# ==============================================================================
resource "azurerm_virtual_network_peering" "hub_to_app" {
  name                         = "peer-hub-to-app"
  resource_group_name          = var.rgname
  virtual_network_name         = module.hub.vnet_name
  remote_virtual_network_id    = module.app.vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  depends_on                   = [azurerm_resource_group.team02_rg]
}

resource "azurerm_virtual_network_peering" "app_to_hub" {
  name                         = "peer-app-to-hub"
  resource_group_name          = var.rgname
  virtual_network_name         = module.app.vnet_name
  remote_virtual_network_id    = module.hub.vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  use_remote_gateways          = true
  depends_on                   = [azurerm_virtual_network_peering.hub_to_app]
}

# ==============================================================================
# DMZ <-> App Peering
# ==============================================================================
resource "azurerm_virtual_network_peering" "dmz_to_app" {
  name                         = "peer-dmz-to-app"
  resource_group_name          = var.rgname
  virtual_network_name         = module.dmz.vnet_name
  remote_virtual_network_id    = module.app.vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  depends_on                   = [azurerm_resource_group.team02_rg]
}

resource "azurerm_virtual_network_peering" "app_to_dmz" {
  name                         = "peer-app-to-dmz"
  resource_group_name          = var.rgname
  virtual_network_name         = module.app.vnet_name
  remote_virtual_network_id    = module.dmz.vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  depends_on                   = [azurerm_resource_group.team02_rg]
}