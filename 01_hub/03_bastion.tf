# Bastion Host
resource "azurerm_bastion_host" "hub_bastion" {
  name                = "${var.prefix}-bastion"
  location            = var.location
  resource_group_name = var.rgname

  ip_configuration {
    name                 = "${var.prefix}-configuration"
    subnet_id            = azurerm_subnet.hub_bat_snet.id
    public_ip_address_id = azurerm_public_ip.hub_bat_pubip.id
  }
}

# Management Server NIC
resource "azurerm_network_interface" "hub_mgmt_nic" {
  name                = "${var.prefix}-mgmt-nic"
  location            = var.location
  resource_group_name = var.rgname

  ip_configuration {
    name                          = "${var.prefix}-mgmt-nic-ipcon"
    subnet_id                     = azurerm_subnet.hub_mgmt_snet.id
    private_ip_address_allocation = "Dynamic"
    private_ip_address_version    = "IPv4"
  }
}

# Management Server VM
resource "azurerm_linux_virtual_machine" "hub_mgmtvm" {
  name                  = "${var.prefix}-mgmtvm"
  resource_group_name   = var.rgname
  location              = var.location
  size                  = "Standard_B2s"
  admin_username        = var.username
  network_interface_ids = [azurerm_network_interface.hub_mgmt_nic.id]
  
  user_data = base64encode(templatefile("${path.module}/bastion_init.yaml", {
    username    = var.username
    private_key = base64encode(var.ssh_private_key)
  }))
  
  admin_ssh_key {
    public_key = var.ssh_public_key
    username   = var.username
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
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
  
  boot_diagnostics {
    storage_account_uri = null
  }
}