output "vnet_name" { value = azurerm_virtual_network.main.name }
output "vnet_id" { value = azurerm_virtual_network.main.id }
output "functions_subnet_id" { value = azurerm_subnet.functions.id }
output "private_subnet_id" { value = azurerm_subnet.private.id }