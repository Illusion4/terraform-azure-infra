variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "environment" {
  type = string
}

variable "project_name" {
  type = string
}

variable "unique_suffix" {
  type = string
}

variable "storage_account_name" {
  type = string
}

variable "storage_account_key" {
  type      = string
  sensitive = true
}

variable "storage_connection_string" {
  type      = string
  sensitive = true
}

variable "subnet_id" {
  type = string
}

variable "key_vault_id" {
  type = string
}

variable "application_insights_key" {
  type    = string
  default = null
}

variable "application_insights_conn" {
  type    = string
  default = null
}

variable "additional_app_settings" {
  type = map(string)
}

variable "tags" {
  type = map(string)
}