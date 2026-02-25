# VPN Gateway
resource "azurerm_virtual_network_gateway" "hub_vpn_gw" {
  name                = "${var.prefix}-vpn-gateway"
  location            = var.location
  resource_group_name = var.rgname

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "VpnGw1"

  ip_configuration {
    name                          = "${var.prefix}-gw-config"
    public_ip_address_id          = azurerm_public_ip.vpn_pubip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.hub_gateway_snet.id
  }
}

# Local Network Gateway (On-Premises Info)
resource "azurerm_local_network_gateway" "onprem" {
  name                = "${var.prefix}-onprem-lng"
  location            = var.location
  resource_group_name = var.rgname

  gateway_address = var.onprem_public_ip
  address_space   = var.onprem_cidr
}

# VPN Connection Settings
resource "azurerm_virtual_network_gateway_connection" "onprem_conn" {
  name                = "${var.prefix}-to-onprem-conn"
  location            = var.location
  resource_group_name = var.rgname

  type = "IPsec"

  virtual_network_gateway_id = azurerm_virtual_network_gateway.hub_vpn_gw.id
  local_network_gateway_id   = azurerm_local_network_gateway.onprem.id
  shared_key                 = var.vpn_shared_key
  
  ipsec_policy {
    dh_group         = var.vpn_policy["dh_group"]
    ike_encryption   = var.vpn_policy["ike_encryption"]
    ike_integrity    = var.vpn_policy["ike_integrity"]
    ipsec_encryption = var.vpn_policy["ipsec_encryption"]
    ipsec_integrity  = var.vpn_policy["ipsec_integrity"]
    pfs_group        = var.vpn_policy["pfs_group"]
    sa_lifetime      = var.vpn_policy["sa_lifetime"]
  }
}