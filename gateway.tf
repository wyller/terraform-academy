# Criar IP publico para o Gateway
resource "azurerm_public_ip" "my_nat_gw_public_ip" {
  name                = "myNATGatewayIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = var.quality_std
  zones               = var.zones
}
# Cria um recurso NAT para gateway
resource "azurerm_nat_gateway" "my_nat_gw" {
  name                    = "myNatGateway"
  location                = azurerm_resource_group.rg.location
  resource_group_name     = azurerm_resource_group.rg.name
  sku_name                = var.quality_std
  idle_timeout_in_minutes = 10
}
# Associa gateway com o IP publico
resource "azurerm_nat_gateway_public_ip_association" "my_gw_ip_association" {
  nat_gateway_id       = azurerm_nat_gateway.my_nat_gw.id
  public_ip_address_id = azurerm_public_ip.my_nat_gw_public_ip.id
}
# Associa gateway com a subnet
resource "azurerm_subnet_nat_gateway_association" "my_nat_gw_association" {
  subnet_id      = azurerm_subnet.my_backend_subnet.id
  nat_gateway_id = azurerm_nat_gateway.my_nat_gw.id
}
