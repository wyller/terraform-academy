resource "random_pet" "rg_name" {
  prefix = var.resource_group_name_prefix
}
# Gerar grupo de recursos
resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = random_pet.rg_name.id
}
# Criar Rede Virtual
resource "azurerm_virtual_network" "myvnet" {
  name                = "myVNet"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}
# Criar SubNet para Servidores Backend
resource "azurerm_subnet" "my_backend_subnet" {
  name                 = "myBackendSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.myvnet.name
  address_prefixes     = ["10.1.0.0/24"]
}
# Criar IP publico para o LB
resource "azurerm_public_ip" "my_public_ip" {
  name                = "myPublicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = var.quality_std
  zones               = var.zones
}
# Criar um load balancer (LB)
resource "azurerm_lb" "my_load_balancer" {
  name                = "myLoadBalancer"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = var.quality_std
  frontend_ip_configuration {
    name                 = "myFrontEnd"
    public_ip_address_id = azurerm_public_ip.my_public_ip.id
  }
}
# Gerar um backend pool
resource "azurerm_lb_backend_address_pool" "my_backend_pool" {
  loadbalancer_id = azurerm_lb.my_load_balancer.id
  name            = "myBackEndPool"
}
# Gerar um probe de saude do load balancer
resource "azurerm_lb_probe" "my_load_balancer_probe" {
  loadbalancer_id = azurerm_lb.my_load_balancer.id
  name            = "myHealthProbe"
  port            = 80
  protocol        = "Tcp"
}
# Criar regra de Load Balancer
resource "azurerm_lb_rule" "my_load_balancer_rule" {
  probe_id                       = azurerm_lb_probe.my_load_balancer_probe.id
  loadbalancer_id                = azurerm_lb.my_load_balancer.id
  name                           = "myHTTPRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "myFrontEnd"
  disable_outbound_snat          = "true"
  idle_timeout_in_minutes        = 15
  enable_tcp_reset               = "true"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.my_backend_pool.id]
}
# Criar grupo de seguranca de rede e regra
resource "azurerm_network_security_group" "my_nsg" {
  name                = "myNSG"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  security_rule {
    name                       = "myNSGRuleHTTP"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
