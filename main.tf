terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
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

# Local file download using external source (ZIP from GitHub)
resource "null_resource" "download_and_unzip" {
  provisioner "local-exec" {
    command = <<EOT
      set -e
      echo "Cleaning up old files..."
      rm -rf New.zip unzipped

      echo "Downloading ZIP..."
      curl -L -o New.zip "https://github.com/AKTECHLEARN/TESTZIP/raw/main/New.zip"

      echo "Unzipping..."
      mkdir -p unzipped
      unzip New.zip -d unzipped
    EOT
  }
}

# Upload each file inside `unzipped/` directory to the blob storage
resource "azurerm_storage_blob" "uploaded_files" {
  for_each = fileset("${path.module}/unzipped", "**/*")

  name                   = each.value
  storage_account_name   = "kusaltest"
  storage_container_name = "mycontainer"
  type                   = "Block"
  source                 = "${path.module}/unzipped/${each.value}"
}
