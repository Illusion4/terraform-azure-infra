variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "azfuncapp"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    ManagedBy   = "Terraform"
    Project     = "AzureFunctionApp"
  }
}

variable "allowed_ips" {
  description = "IP addresses allowed to access Key Vault"
  type        = list(string)
  default     = []
}

variable "enable_monitoring" {
  description = "Enable Application Insights monitoring"
  type        = bool
  default     = true
}

variable "function_app_settings" {
  description = "Additional app settings for Function App"
  type        = map(string)
  default     = {}
}

variable "vnet_address_space" {
  description = "Address space for virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_prefixes" {
  description = "Subnet address prefixes"
  type        = map(string)
  default = {
    functions = "10.0.1.0/24"
    private   = "10.0.2.0/24"
  }
}