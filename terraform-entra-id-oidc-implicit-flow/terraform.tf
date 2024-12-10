terraform {
  required_version = "~> 1.10.0"

  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.15"
    }

    google = {
      source  = "hashicorp/google"
      version = "~> 6.12"
    }
  }
}

provider "azuread" {
  tenant_id = var.tenant_id
}

provider "google" {
  billing_project = var.project_id
}
