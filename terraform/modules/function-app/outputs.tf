output "function_app_name" {
  value = azurerm_linux_function_app.main.name
}

output "function_app_id" {
  value = azurerm_linux_function_app.main.id
}

output "function_app_default_hostname" {
  value = azurerm_linux_function_app.main.default_hostname
}

output "function_app_identity" {
  value = {
    principal_id = azurerm_linux_function_app.main.identity[0].principal_id
    tenant_id    = azurerm_linux_function_app.main.identity[0].tenant_id
  }
  sensitive = true
}