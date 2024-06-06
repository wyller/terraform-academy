# Criar Bastion IP publico
resource "azurerm_public_ip" "my_bastion_ip" {
  name                = "bastionPublicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
}
# Criar Bastion SubNet
resource "azurerm_subnet" "my_bastion_subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.myvnet.name
  address_prefixes     = ["10.1.1.0/27"]
}
# Criar o Bastion Host
resource "azurerm_bastion_host" "my_bastion_host" {
  name                = "bastionHost"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
  tunneling_enabled   = "true"
  ip_configuration {
    name                 = "bastionIpConfiguration"
    subnet_id            = azurerm_subnet.my_bastion_subnet.id
    public_ip_address_id = azurerm_public_ip.my_bastion_ip.id
  }
}
