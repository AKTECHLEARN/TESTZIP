terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features = {}
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
}

variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}
variable "subscription_id" {}

variable "storage_account_name" {
  default = "kusaltest"
}

variable "container_name" {
  default = "mycontainer"
}

resource "null_resource" "extract_and_upload" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command = <<EOT
set -e

echo "Cleaning up old files..."
rm -rf New.zip unzipped

echo "Downloading ZIP..."
curl -L -o New.zip "https://github.com/AKTECHLEARN/TESTZIP/raw/main/New.zip"

echo "Unzipping..."
mkdir -p unzipped
unzip New.zip -d unzipped

echo "Logging into Azure..."
az login --service-principal \
  --username "$ARM_CLIENT_ID" \
  --password "$ARM_CLIENT_SECRET" \
  --tenant "$ARM_TENANT_ID" > /dev/null

echo "Uploading files to blob..."
az storage blob upload-batch \
  --account-name ${var.storage_account_name} \
  --destination ${var.container_name} \
  --source unzipped \
  --auth-mode login \
  --no-progress

echo "Upload completed!"
EOT
  }

  triggers = {
    always_run = timestamp()
  }
}
