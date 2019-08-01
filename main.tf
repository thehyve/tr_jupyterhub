# main.tf

# Define terraform backend
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

# Definition of variables
variable "hcloud_token" {
  type = string
  description = "Use -var='hcloud_token=...' CLI option"
}
variable "server_type" {
  type = string
  description = "defines resources for provisioned server"
  default = "cx31-ceph"
}
variable "ssh_key_private" {
  type = string
  description = "Ssh private key to use for connection to a server. Export TF_VAR_ssh_key_private environment variable to define a value."
}
variable "ssh_key" {
  type = string
  description = "An id of public key of ssh key-pairs that will be used for connection to a server. Export TF_VAR_ssh_key environment variable to define a value."
}
variable "remote_user" {
  type = string
  description = "A user being used for a connection to a server. By default is root, unless redefined with user-data (cloud-init)."
  default = "root"
}
variable "jh_server_name" {
  type = string
  description = "Hostname for JupyterHub server"
  default = "jh"
}
variable "jh_location" {
  type = string
  description = "Location of JupyterHub server"
  default = "fsn1"
}
variable "server_image" {
  type = string
  description = "An image being used for a server provisioning."
  default = "centos-7"
}
variable "domain" {
  type = string
  description = "A domain name for FreeIPA server. Export TF_VAR_domain environment variable to define."
}

# User Hetzner cloud
provider "hcloud" {
  token = "${var.hcloud_token}"
}

# Get data from Hetzner cloud
data "hcloud_floating_ip" "jh" {
  with_selector = "server==jupyterhub"
}
data "hcloud_volume" "jh" {
  with_selector = "server==jupyterhub"
}

# Create resources
resource "hcloud_server" "jh" {
  name = "${var.jh_server_name}"
  server_type = "${var.server_type}"
  keep_disk = true
  backups = true
  image = "${var.server_image}"
  location = "${var.jh_location}"
  ssh_keys = [
    "${var.ssh_key}",
  ]
  provisioner "remote-exec" {
    inline = [
      "yum install python libselinux-python -y"
    ]
    connection {
      host = "${hcloud_server.jh.ipv4_address}"
      type = "ssh"
      user = "${var.remote_user}"
      private_key = "${file("${var.ssh_key_private}")}"
    }
  }
}

# Attach volume
resource "hcloud_volume_attachment" "jh" {
  volume_id = "${data.hcloud_volume.jh.id}"
  server_id = "${hcloud_server.jh.id}"
}
# Assign floating IP
resource "hcloud_floating_ip_assignment" "jh" {
  floating_ip_id = "${data.hcloud_floating_ip.jh.id}"
  server_id = "${hcloud_server.jh.id}"
}
