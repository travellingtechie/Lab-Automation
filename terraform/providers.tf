# Load Providers

terraform {
  required_providers {
    nsxt = {
      source = "vmware/nsxt"
    }
  }
}

provider "nsxt" {
    host = "${var.nsx["ip"]}"
    username = "${var.nsx["user"]}"
    password = "${var.nsx["password"]}"
    allow_unverified_ssl = true
}

# Configure the VMware vSphere Provider
#provider "vsphere" {
#    user           = "${var.vsphere["vsphere_user"]}"
#    password       = "${var.vsphere["vsphere_password"]}"
#    vsphere_server = "${var.vsphere["vsphere_ip"]}"
#    allow_unverified_ssl = true
#}