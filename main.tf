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

# Upload all files from unzipped directory recursively
resource "azurerm_storage_blob" "upload_blobs" {
  for_each = fileset("${path.module}/unzipped", "**/*")  # 🔁 Recursively match ALL files

  name                   = each.value                     # Preserves folder structure in blob name
  storage_account_name   = "kusaltest"
  storage_container_name = "mycontainer"
  type                   = "Block"
  source                 = "${path.module}/unzipped/${each.value}"
}
