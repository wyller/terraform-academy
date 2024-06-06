# Create network interface
resource "azurerm_network_interface" "my_vm1_nic" {
  name                = "myNicVM1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "nicVM1Configuration"
    subnet_id                     = azurerm_subnet.my_backend_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_network_interface" "my_vm2_nic" {
  name                = "myNicVM2"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "nicVM2configuration"
    subnet_id                     = azurerm_subnet.my_backend_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}
# Adiciona VM1 no Address pool
resource "azurerm_network_interface_backend_address_pool_association" "my_nic_vm1_addresspool" {
  network_interface_id    = azurerm_network_interface.my_vm1_nic.id
  ip_configuration_name   = "nicVM1Configuration"
  backend_address_pool_id = azurerm_lb_backend_address_pool.my_backend_pool.id
}

# Adiciona VM2 no Address pool
resource "azurerm_network_interface_backend_address_pool_association" "my_nic_vm2_addresspool" {
  network_interface_id    = azurerm_network_interface.my_vm2_nic.id
  ip_configuration_name   = "nicVM2configuration"
  backend_address_pool_id = azurerm_lb_backend_address_pool.my_backend_pool.id
}
# Conecta NSG com VM1
resource "azurerm_network_interface_security_group_association" "net_nsg_vm1" {
  network_interface_id      = azurerm_network_interface.my_vm1_nic.id
  network_security_group_id = azurerm_network_security_group.my_nsg.id
}
# Conecta NSG com VM2
resource "azurerm_network_interface_security_group_association" "net_nsg_vm2" {
  network_interface_id      = azurerm_network_interface.my_vm2_nic.id
  network_security_group_id = azurerm_network_security_group.my_nsg.id
}
# Gera texto randomico para storage
resource "random_id" "random_vm1_id" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.rg.name
  }
  byte_length = 8
}
# Gera texto randomico para storage
resource "random_id" "random_vm2_id" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.rg.name
  }
  byte_length = 8
}
# Cria conta storage VM1 pra diagnosticar boot
resource "azurerm_storage_account" "my_vm1_storage_account" {
  name                     = "diag${random_id.random_vm1_id.hex}"
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
# Cria conta storage VM2 pra diagnosticar boot
resource "azurerm_storage_account" "my_vm2_storage_account" {
  name                     = "diag${random_id.random_vm2_id.hex}"
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
# Cria VM1
resource "azurerm_linux_virtual_machine" "my_vm1" {
  name                  = "myVM1"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.my_vm1_nic.id]
  size                  = "Standard_DS1_v2"
  os_disk {
    name                 = "myVM1OsDisk"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
  computer_name  = "vm1"
  admin_username = var.username
  admin_ssh_key {
    username   = var.username
    public_key = azapi_resource_action.ssh_public_key_gen.output.publicKey
  }
  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.my_vm1_storage_account.primary_blob_endpoint
  }
}
# Cria VM2
resource "azurerm_linux_virtual_machine" "my_vm2" {
  name                  = "myVM2"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.my_vm2_nic.id]
  size                  = "Standard_DS1_v2"
  os_disk {
    name                 = "myVM2OsDisk"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
  computer_name  = "vm2"
  admin_username = var.username
  admin_ssh_key {
    username   = var.username
    public_key = azapi_resource_action.ssh_public_key_gen.output.publicKey
  }
  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.my_vm2_storage_account.primary_blob_endpoint
  }
}
