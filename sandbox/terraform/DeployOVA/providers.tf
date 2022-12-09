#! providers.tf

terraform {
  required_providers {
    nsxt = {
      source = "vmware/nsxt"
    }

  }
}

# Configure the NSX-T Provider
provider "nsxt" {
    host = "${var.nsx["hostname"]}"
    username = "${var.nsx["user"]}"
    password = "${var.nsx["password"]}"
    allow_unverified_ssl = true
}

# Configure the VMware vSphere Provider
provider "vsphere" {
    user           = "${var.vsphere["user"]}"
    password       = "${var.vsphere["password"]}"
    vsphere_server = "${var.vsphere["hostname"]}"
    allow_unverified_ssl = true
}