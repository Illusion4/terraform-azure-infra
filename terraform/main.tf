locals {
  resource_suffix = "${var.project_name}-${var.environment}"
  common_tags = merge(var.tags, {
    Environment = var.environment
    DeployedAt  = timestamp()
  })
}

resource "random_string" "unique" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_resource_group" "main" {
  name     = "rg-${local.resource_suffix}"
  location = var.location
  tags     = local.common_tags
}

module "networking" {
  source = "./modules/networking"
  
  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  environment        = var.environment
  project_name       = var.project_name
  vnet_address_space = var.vnet_address_space
  subnet_prefixes    = var.subnet_prefixes
  tags               = local.common_tags
}

module "storage" {
  source = "./modules/storage"
  
  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  environment        = var.environment
  project_name       = var.project_name
  unique_suffix      = random_string.unique.result
  tags               = local.common_tags
}

module "key_vault" {
  source = "./modules/key-vault"
  
  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  environment        = var.environment
  project_name       = var.project_name
  unique_suffix      = random_string.unique.result
  allowed_ips        = var.allowed_ips
  subnet_id          = module.networking.private_subnet_id
  tags               = local.common_tags
}

resource "azurerm_application_insights" "main" {
  count               = var.enable_monitoring ? 1 : 0
  name                = "appi-${local.resource_suffix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  application_type    = "web"
  tags                = local.common_tags
}

module "function_app" {
  source = "./modules/function-app"
  
  resource_group_name          = azurerm_resource_group.main.name
  location                     = azurerm_resource_group.main.location
  environment                  = var.environment
  project_name                 = var.project_name
  unique_suffix                = random_string.unique.result
  storage_account_name         = module.storage.storage_account_name
  storage_account_key          = module.storage.storage_account_key
  storage_connection_string    = module.storage.storage_connection_string
  subnet_id                    = module.networking.functions_subnet_id
  key_vault_id                 = module.key_vault.key_vault_id
  application_insights_key     = var.enable_monitoring ? azurerm_application_insights.main[0].instrumentation_key : null
  application_insights_conn    = var.enable_monitoring ? azurerm_application_insights.main[0].connection_string : null
  additional_app_settings      = var.function_app_settings
  tags                         = local.common_tags
}

resource "azurerm_key_vault_secret" "storage_connection" {
  name         = "StorageConnectionString"
  value        = module.storage.storage_connection_string
  key_vault_id = module.key_vault.key_vault_id

  depends_on = [module.key_vault]
}

resource "azurerm_key_vault_secret" "app_insights_key" {
  count        = var.enable_monitoring ? 1 : 0
  name         = "ApplicationInsightsKey"
  value        = azurerm_application_insights.main[0].instrumentation_key
  key_vault_id = module.key_vault.key_vault_id

  depends_on = [module.key_vault]
}