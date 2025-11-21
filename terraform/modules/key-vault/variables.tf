variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "environment" { type = string }
variable "project_name" { type = string }
variable "unique_suffix" { type = string }
variable "allowed_ips" { type = list(string) }
variable "subnet_id" { type = string }
variable "tags" { type = map(string) }