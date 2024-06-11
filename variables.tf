variable "resource_group_location" {
  type        = string
  default     = "eastus"
  description = "Local do grupo de recursos"
}
variable "resource_group_name_prefix" {
  type        = string
  default     = "rg"
  description = "Prefixo para o grupo de recursos que vai ser combinado com um nome randomico."
}
variable "username" {
  type        = string
  description = "O usuario que vai ser usado pra acessar a VM."
  default     = "azureadmin"
}
variable "subscription_id" {
  type        = string
  description = "azure subscription id"
}
variable "tenant_id" {
  type        = string
  description = "azure tenant id"
}
variable "client_id" {
  type        = string
  description = "azure client id"
}
variable "client_secret" {
  type        = string
  description = "azure clinet secret"
}
variable "zones" {
  type        = list(any)
  description = "Todas as zonas envolvidas naquela regiao."
  default     = ["1", "2", "3"]
}
variable "quality_std" {
  type        = string
  description = "Todas as zonas envolvidas naquela regiao."
  default     = "Standard"
}
