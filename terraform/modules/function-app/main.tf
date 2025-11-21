resource "azurerm_service_plan" "main" {
  name                = "asp-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = var.environment == "prod" ? "P1v3" : "B1"
  tags                = var.tags
}

resource "azurerm_linux_function_app" "main" {
  name                       = "func-${var.project_name}-${var.environment}-${var.unique_suffix}"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  service_plan_id            = azurerm_service_plan.main.id
  storage_account_name       = var.storage_account_name
  storage_account_access_key = var.storage_account_key
  https_only                 = true

  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_stack {
      dotnet_version              = "8.0"
      use_dotnet_isolated_runtime = true
    }

    ftps_state             = "Disabled"
    http2_enabled          = true
    minimum_tls_version    = "1.2"
    vnet_route_all_enabled = true

    cors {
      allowed_origins = ["https://portal.azure.com"]
    }
  }

  app_settings = merge({
    "FUNCTIONS_WORKER_RUNTIME"                 = "dotnet-isolated"
    "AzureWebJobsStorage"                      = var.storage_connection_string
    "WEBSITE_CONTENTAZUREFILECONNECTIONSTRING" = var.storage_connection_string
    "WEBSITE_CONTENTSHARE"                     = "func-${var.project_name}-${var.environment}"
    "KeyVaultName"                             = split("/", var.key_vault_id)[8]
    "APPINSIGHTS_INSTRUMENTATIONKEY"           = var.application_insights_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING"    = var.application_insights_conn
  }, var.additional_app_settings)

  virtual_network_subnet_id = var.subnet_id

  tags = var.tags
}

resource "azurerm_key_vault_access_policy" "function_app" {
  key_vault_id = var.key_vault_id
  tenant_id    = azurerm_linux_function_app.main.identity[0].tenant_id
  object_id    = azurerm_linux_function_app.main.identity[0].principal_id

  secret_permissions = ["Get", "List"]
}