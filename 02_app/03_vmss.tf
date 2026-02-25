# Internal Load Balancer
resource "azurerm_lb" "app_lb" {
  name                = "${var.prefix}-ilb"
  location            = var.location
  resource_group_name = var.rgname
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "LoadBalancerFrontEnd"
    subnet_id                     = azurerm_subnet.app_snet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.lb_private_ip
  }
}

resource "azurerm_lb_backend_address_pool" "app_bep" {
  loadbalancer_id = azurerm_lb.app_lb.id
  name            = "bep-web-vms"
}

resource "azurerm_lb_probe" "http_probe" {
  loadbalancer_id = azurerm_lb.app_lb.id
  name            = "http-probe"
  port            = 80
  protocol        = "Http"
  request_path    = "/health.html"
}

resource "azurerm_lb_rule" "rule_80" {
  loadbalancer_id                = azurerm_lb.app_lb.id
  name                           = "Http-Rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.app_bep.id]
  probe_id                       = azurerm_lb_probe.http_probe.id
}

# Virtual Machine Scale Set
resource "azurerm_linux_virtual_machine_scale_set" "app_vmss" {
  name                            = "${var.prefix}-vmss"
  resource_group_name             = var.rgname
  location                        = var.location
  sku                             = "Standard_B2s"
  instances                       = var.vm_count
  admin_username                  = var.username
  disable_password_authentication = true
  upgrade_mode                    = "Automatic"
  zones                           = ["1", "2", "3"]

  admin_ssh_key {
    username   = var.username
    public_key = var.ssh_public_key
  }

  os_disk {
    storage_account_type = "StandardSSD_LRS"
    caching              = "ReadWrite"
  }

  source_image_reference {
    publisher = "resf"
    offer     = "rockylinux-x86_64"
    sku       = "9-lvm"
    version   = "9.6.20250531"
  }

  plan {
    publisher = "resf"
    product   = "rockylinux-x86_64"
    name      = "9-lvm"
  }

  network_interface {
    name    = "vmss-nic"
    primary = true

    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                              = azurerm_subnet.app_snet.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.app_bep.id]
    }
  }

  user_data = base64encode(replace(templatefile("${path.module}/web_init.yaml", {
    domain_name = var.domain_name
  }), "\r", ""))

  boot_diagnostics {
    storage_account_uri = null
  }
}