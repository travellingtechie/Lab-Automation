terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = ">= 2.2.0"
    }
  }
}

provider "vsphere" {
  user           = "administrator@vsphere.local"
  password       = "password"
  vsphere_server = "galactica.lab.travellingtechie.com"
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "datacenter" {
  name = "Homelab"
}

data "vsphere_datastore" "datastore" {
  name          = "Lab NFS"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = "Physical"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_resource_pool" "default" {
  name          = format("%s%s", data.vsphere_compute_cluster.cluster.name, "/Resources")
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_host" "host" {
  name          = "rama11.lab.travellingtechie.com"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "network" {
  name          = "Lab MGMT Local"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_folder" "folder" {
  path = "/${data.vsphere_datacenter.datacenter.name}/vm/Connectors"
}

## Local OVF/OVA Source
data "vsphere_ovf_vm_template" "ovfLocal" {
  name              = "foo"
  disk_provisioning = "thin"
  resource_pool_id  = data.vsphere_resource_pool.default.id
  datastore_id      = data.vsphere_datastore.datastore.id
  host_system_id    = data.vsphere_host.host.id
  local_ovf_path    = "/Users/brandonneill/Projects/Terraform/nsx-unified-appliance-3.1.2.0.0.17884005-le.ova"
  ovf_network_map = {
      "VM Network" : data.vsphere_network.network.id
  }
}

## Deployment of VM from Local OVF
resource "vsphere_virtual_machine" "vmFromLocalOvf" {
  name                 = "Babylon5"
  folder               = trimprefix(data.vsphere_folder.folder.path, "/${data.vsphere_datacenter.datacenter.name}/vm/Connectors")
  datacenter_id        = data.vsphere_datacenter.datacenter.id
  datastore_id         = data.vsphere_datastore.datastore.id
  host_system_id       = data.vsphere_host.host.id
  resource_pool_id     = data.vsphere_resource_pool.default.id
  num_cpus             = data.vsphere_ovf_vm_template.ovfLocal.num_cpus
  num_cores_per_socket = data.vsphere_ovf_vm_template.ovfLocal.num_cores_per_socket
  memory               = data.vsphere_ovf_vm_template.ovfLocal.memory
  guest_id             = data.vsphere_ovf_vm_template.ovfLocal.guest_id
  scsi_type            = data.vsphere_ovf_vm_template.ovfLocal.scsi_type
  nested_hv_enabled    = data.vsphere_ovf_vm_template.ovfLocal.nested_hv_enabled
  dynamic "network_interface" {
      for_each = data.vsphere_ovf_vm_template.ovfLocal.ovf_network_map
      content {
      network_id = network_interface.value
      }
  }
  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout  = 0

  ovf_deploy {
      allow_unverified_ssl_cert = false
      local_ovf_path            = data.vsphere_ovf_vm_template.ovfLocal.local_ovf_path
      disk_provisioning         = data.vsphere_ovf_vm_template.ovfLocal.disk_provisioning
      ovf_network_map           = data.vsphere_ovf_vm_template.ovfLocal.ovf_network_map
  }

  lifecycle {
      ignore_changes = [
      annotation,
      disk[0].io_share_count,
      disk[1].io_share_count,
      disk[2].io_share_count,
      vapp[0].properties,
      ]
  }
}