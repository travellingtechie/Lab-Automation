# Variables for NSX
#variable "nsx" {
#  type = map
#  description = "NSX Login Details"
#  default = {
#    hostname  = "192.168.110.201"
#    user = "admin"
#    password = "Password"
#  }
#}

# Variables for vSphere
variable "vsphere" {
  type        = map
  description = "vSphere Details"
  default     = {
    user     = "administrator@vsphere.local"
    password = "VMware1!"
    hostname       = "vcenter.lab.local"
  }
}

# vsphere infrastructure variables
variable "infra"  {
  type = map
  description = "vSphere Infrastructure"
  default = {
    datacenter = "Homelab"
    cluster = "Physical"
    datastore = "Lab NFS"
    host = "rama11.lab.travellingtechie.com"
    network = "Lab MGMT Local"
    folder = "Terraform"
  }
}

# VM variables
variable "VM" {
  type = map
  description = "VM Variables"
  default = {
    name = "Ubuntu-01"
    ova = "kinetic-server-cloudimg-amd64.ova"

  }
}
