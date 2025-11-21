environment = "prod"
location    = "germanywestcentral"

tags = {
  Environment = "prod"
  ManagedBy   = "Terraform"
  Project     = "AzureFunctionApp"
}

allowed_ips = [
  "203.0.113.10/32",
  "203.0.113.42/32"
]

enable_monitoring = true

function_app_settings = {
  "APPLICATION_ENVIRONMENT" = "Production"
}

vnet_address_space = [
  "10.2.0.0/16"
]

subnet_prefixes = {
  functions = "10.2.1.0/24"
  private   = "10.2.2.0/24"
}
