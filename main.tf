terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.6.0"
}

provider "azurerm" {
  features {}

  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
}

variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}
variable "subscription_id" {}

# Upload files inside the unzipped folder to blob storage
resource "azurerm_storage_blob" "upload_blobs" {
  for_each = fileset("${path.module}/unzipped/New folder", "**/*")

  name                   = each.value
  storage_account_name   = "kusaltest"       # ✅ Replace with your actual storage account
  storage_container_name = "mycontainer"     # ✅ Replace with your actual container name
  type                   = "Block"
  source                 = "${path.module}/unzipped/New folder/${each.value}"
}
