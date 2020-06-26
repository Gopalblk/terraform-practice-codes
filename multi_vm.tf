# Configure the Microsoft Azure Provider
provider "azurerm" {
    # The "feature" block is required for AzureRM provider 2.x.
    # If you're using version 1.x, the "features" block is not allowed.
    version = "~>2.0"
    features {}
}

# Create a resource group if it doesn't exist
resource "azurerm_resource_group" "rg" {
    name     = "${var.prefix}-${var.location}-rg"
    location = "${var.location}"
    tags = {
        environment = "Terraform group"
    }
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "web" {
  name                 = "web"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix       = "10.0.2.0/24"
}

# Create public IPs
resource "azurerm_public_ip" "pubip" {
    count                        = 2
    name                         = "webpubip${count.index}"
    location                     = azurerm_resource_group.rg.location
    resource_group_name          = azurerm_resource_group.rg.name
    allocation_method            = "Dynamic"

    tags = {
        environment = "Terraform group"
    }
}

#Create NIC
resource "azurerm_network_interface" "webnic" {
  count                     = 2
  name                      = "${var.prefix}webnic${count.index}"
  location                  = var.location
  resource_group_name       = azurerm_resource_group.rg.name
#  network_security_group_id = azurerm_network_security_group.nsg.id
  #tags                      = var.tags

  ip_configuration {
    name                          = "${var.prefix}webniccfg"
    subnet_id                     = azurerm_subnet.web.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.pubip[count.index].id}"
  }
}

# Create a Linux virtual machine
resource "azurerm_virtual_machine" "vm" {
  count                 = 2
  name                  = "${var.prefix}webvm${count.index}"
  location              = var.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [element(azurerm_network_interface.webnic.*.id, count.index)]
  vm_size               = "Standard_DS1_v2"
  #tags                  = var.tags

  storage_os_disk {
    name              = "${var.prefix}osdisk${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = lookup(var.sku, var.location)
    version   = "latest"
  }

  os_profile {
    computer_name  = "${var.prefix}webvm${count.index}"
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

resource "azurerm_managed_disk" "data" {
  count                =  2
  name                 = "webdata${count.index}"
  location             = var.location
  create_option        = "Empty"
  disk_size_gb         = 10
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "Standard_LRS"
}

resource "azurerm_virtual_machine_data_disk_attachment" "data" {
  count              = 2
  managed_disk_id    = element(azurerm_managed_disk.data.*.id, count.index)
  virtual_machine_id = "${azurerm_virtual_machine.vm[count.index].id}"
  lun                =  count.index + 1
  caching            = "None"
}
