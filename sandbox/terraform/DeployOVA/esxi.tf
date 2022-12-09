# esxi.tf
# Not yet Functioning

# vSphere Infrastructure Details
data "vsphere_datacenter" "datacenter" {
  name = "${var.infra["datacenter"]}"
}

data "vsphere_datastore" "datastore" {
  name          = "${var.infra["datastore"]}"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = "${var.infra["cluster"]}"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_resource_pool" "default" {
  name          = format("%s%s", data.vsphere_compute_cluster.cluster.name, "/Resources")
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_host" "host" {
  name          = "${var.infra["host"]}"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "network" {
  name          = "${var.infra["network"]}"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_folder" "folder" {
  path = "/${data.vsphere_datacenter.datacenter.name}/vm/${var.infra["folder"]}"
}

## Local OVF/OVA Source
data "vsphere_ovf_vm_template" "ovaLocal" {
  name              = "ovaLocal"
  disk_provisioning = "thin"
  resource_pool_id  = data.vsphere_resource_pool.default.id
  datastore_id      = data.vsphere_datastore.datastore.id
  host_system_id    = data.vsphere_host.host.id
  local_ovf_path    = "${var.VM["ova"]}"
  ovf_network_map = {
      "Lab Network" : data.vsphere_network.network.id
  }
}
## Deployment of DRaaS-Connector1-01
resource "vsphere_virtual_machine" "vm01" {
  name                 = "${var.VM["name"]}"
  folder               = data.vsphere_folder.folder.path
  datacenter_id        = data.vsphere_datacenter.datacenter.id
  datastore_id         = data.vsphere_datastore.datastore.id
  host_system_id       = data.vsphere_host.host.id
  resource_pool_id     = data.vsphere_resource_pool.default.id
  num_cpus             = data.vsphere_ovf_vm_template.ovaLocal.num_cpus
  num_cores_per_socket = data.vsphere_ovf_vm_template.ovaLocal.num_cores_per_socket
  memory               = data.vsphere_ovf_vm_template.ovaLocal.memory
  guest_id             = data.vsphere_ovf_vm_template.ovaLocal.guest_id
  scsi_type            = data.vsphere_ovf_vm_template.ovaLocal.scsi_type
  nested_hv_enabled    = data.vsphere_ovf_vm_template.ovaLocal.nested_hv_enabled
  dynamic "network_interface" {
      for_each = data.vsphere_ovf_vm_template.ovaLocal.ovf_network_map
      content {
      network_id = network_interface.value
      }
  }
  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout  = 0
  cdrom {
    client_device = true
  }
  ovf_deploy {
      allow_unverified_ssl_cert = true
      local_ovf_path            = data.vsphere_ovf_vm_template.ovaLocal.local_ovf_path
      disk_provisioning         = data.vsphere_ovf_vm_template.ovaLocal.disk_provisioning
      ovf_network_map           = data.vsphere_ovf_vm_template.ovaLocal.ovf_network_map
  }

# I don't think this is needed
 vapp {
    properties ={
      hostname = var.VM.name
      user-data = base64encode(file("${path.module}/cloudinit/kickstart.yaml"))
    }
  }

  extra_config = {
    "guestinfo.metadata"          = base64encode(file("${path.module}/cloudinit/metadata.yaml"))
    "guestinfo.metadata.encoding" = "base64"
    "guestinfo.userdata"          = base64encode(file("${path.module}/cloudinit/userdata.yaml"))
    "guestinfo.userdata.encoding" = "base64"
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
