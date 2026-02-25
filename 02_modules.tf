# [00] Policy Module
module "policy" {
  source    = "./00_policy"
  providers = { azurerm = azurerm }

  rgname               = var.rgname
  location             = local.region
  prefix               = "policy"
  username             = var.username
  
  # WAF Policy Settings
  waf_mode             = "Prevention"
  waf_rule_set_version = "3.2"

  depends_on = [azurerm_resource_group.team02_rg]
}

# [01] Hub Module
module "hub" {
  source = "./01_hub"

  rgname                     = var.rgname
  location                   = local.region
  prefix                     = "01-hub"
  vnet_cidr                  = local.hub_cidr
  
  username                   = var.username
  ssh_public_key             = module.policy.ssh_public_key
  ssh_private_key            = module.policy.ssh_private_key
  log_analytics_workspace_id = module.policy.log_analytics_id

  # VPN Configuration
  onprem_public_ip = local.onprem_public_ip
  onprem_cidr      = local.onprem_cidr
  vpn_shared_key   = local.vpn_shared_key
  vpn_policy       = local.vpn_policy

  depends_on = [azurerm_resource_group.team02_rg]
}

# [02] App Module
module "app" {
  source = "./02_app"

  rgname                     = var.rgname
  location                   = local.region
  prefix                     = "02-app"
  vnet_cidr                  = local.app_cidr
  
  hub_vnet_cidr              = local.hub_cidr
  dmz_vnet_cidr              = local.dmz_cidr
  lb_private_ip              = local.app_lb_private_ip
  
  username                   = var.username
  ssh_public_key             = module.policy.ssh_public_key
  vm_count                   = 2
  domain_name                = var.app_domain
  log_analytics_workspace_id = module.policy.log_analytics_id
  onprem_cidr                = local.onprem_cidr

  depends_on = [azurerm_resource_group.team02_rg]
}

# [04] DMZ Module
module "dmz" {
  source = "./04_dmz"

  rgname                     = var.rgname
  location                   = local.region
  prefix                     = "04-dmz"
  vnet_cidr                  = local.dmz_cidr
  
  username                   = var.username
  ssh_public_key             = module.policy.ssh_public_key
  waf_policy_id              = module.policy.waf_id_primary
  
  lb_private_ip              = local.app_lb_private_ip
  app_vnet_cidr              = local.app_cidr
  
  app_domain                 = var.app_domain
  log_analytics_workspace_id = module.policy.log_analytics_id
  eventhub_auth_id           = module.hub.eventhub_auth_id
  eventhub_name              = module.hub.eventhub_name

  depends_on = [azurerm_resource_group.team02_rg]
}