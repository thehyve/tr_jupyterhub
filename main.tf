# main.tf
terraform {
  required_version = "~> 0.12.0"
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "TheHyve"
    workspaces {
      name = "jupyterlab"
    }
  }
}
provider "hcloud" {
}
