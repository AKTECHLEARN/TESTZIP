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

# Required input variables
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}
variable "subscription_id" {}

# Step 1: Download and unzip the GitHub ZIP file
resource "null_resource" "download_and_unzip" {
  provisioner "local-exec" {
    command = <<EOT
      set -e
      echo "Cleaning up..."
      rm -rf New.zip unzipped

      echo "Downloading ZIP file..."
      curl -L -o New.zip "https://github.com/AKTECHLEARN/TESTZIP/raw/main/New.zip"

      echo "Unzipping contents..."
      mkdir -p unzipped
      unzip New.zip -d unzipped
    EOT
  }
}

# Step 2: Upload each file inside the unzipped directory to Azure Blob Storage
resource "azurerm_storage_blob" "uploaded_files" {
  depends_on = [null_resource.download_and_unzip]

  for_each = fileset("${path.module}/unzipped/New folder", "**/*")

  name                   = each.value
  storage_account_name   = "kusaltest"        # Replace with your actual Storage Account name
  storage_container_name = "mycontainer"      # Replace with your actual Container name
  type                   = "Block"
  source                 = "${path.module}/unzipped/New folder/${each.value}"
}
