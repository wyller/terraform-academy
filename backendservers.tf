# Create network interface
resource "azurerm_network_interface" "my_vm_nic" {
  count               = 2
  name                = "myNicVM${count.index}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "nicVM${count.index}Configuration"
    subnet_id                     = azurerm_subnet.my_backend_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Adiciona VMs no Address pool 
resource "azurerm_network_interface_backend_address_pool_association" "my_nic_vm_addresspool" {
  count                   = 2
  network_interface_id    = azurerm_network_interface.my_vm_nic[count.index].id
  ip_configuration_name   = "nicVM${count.index}Configuration"
  backend_address_pool_id = azurerm_lb_backend_address_pool.my_backend_pool.id
}

# Conecta NSG com as VMs
resource "azurerm_network_interface_security_group_association" "net_nsg_vm" {
  count                     = 2
  network_interface_id      = azurerm_network_interface.my_vm_nic[count.index].id
  network_security_group_id = azurerm_network_security_group.my_nsg.id
}

# Gera texto randomico para storage
resource "random_id" "random_vm_id" {
  count = 2
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.rg.name
  }
  byte_length = 8
}

# Cria conta storage VMs pra diagnosticar boot
resource "azurerm_storage_account" "my_vm_storage_account" {
  count                    = 2
  name                     = "diag${random_id.random_vm_id[count.index].hex}"
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = var.quality_std
  account_replication_type = "LRS"
}

# Cria as duas VMs
resource "azurerm_linux_virtual_machine" "my_vms" {
  count                 = 2
  name                  = "myVM${count.index}"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.my_vm_nic[count.index].id]
  size                  = "Standard_DS1_v2"
  os_disk {
    name                 = "myVM${count.index}OsDisk"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
  computer_name  = "vm${count.index}"
  admin_username = var.username
  admin_ssh_key {
    username   = var.username
    public_key = azapi_resource_action.ssh_public_key_gen.output.publicKey
  }
  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.my_vm_storage_account[count.index].primary_blob_endpoint
  }
}
