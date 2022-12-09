# Put variable declarations in here, along with default values
# sensitive variables will be overwritten with data from terraform.tfvars or Environment Variables

# Variables for NSX
variable "nsx" {
  type = map
  description = "NSX Login Details"
  default = {
    hostname  = "nsxmgr.lab.local"
    user = "admin"
    password = "password"
  }
}

# I like to apply a tag to all items deployed from this plan
variable "nsx_tag_scope" {
  type = string
  description = "Scope for the tag that will be applied to all resources"
  default = "tf-plan"
}
variable "nsx_tag" {
  type        = string
  description = "Tag, the value for the scope above"
  default = "demo"
}

# Variables for vSphere
variable "vsphere" {
  type        = map
  description = "vSphere Details"
  default     = {
    hostname = "vcenter.lab.local"
    user     = "administrator@vsphere.local"
    password = "VMware1!"
  }
}

# Plan Specific variables

# Variables for Data Sources

# Transport Zones
variable "transport_zone"  { default = "nsx-overlay-transportzone"}
variable "uplink_vlan_tz" {default = "nsx-uplinks-vlan-transportzone"}

# variable t0_router_name      { default = "T0-GW"}
variable "edge_cluster"      { default = "EdgeCluster"}
variable "edge_node_1" { default = "edgenode-01a"}
variable "edge_node_2" { default = "edgenode-02a"}

# variable t1_router_name     { default = "tf-T1GW"}
variable "dhcp_server"      { default = "Default"}

# Variables for Resources

# T0 and T1 Gateways
# T0 and T1 Gateway Names
variable "t0_gw_name" {default = "Tier0-GW"}
variable "t1_gw_name" {default = "Tier1-GW"}


# VLAN Segments for connecting to TOR-Left and TOR-Right
variable "vlan_right_seg" {default = "right_seg"}
variable "vlans_right_seg" {
  type = list
  description = "Uplink Right Segment VLANs"
  default = ["250"]
}
variable "vlan_left_seg" {default = "left_seg"}
variable "vlans_left_seg" {
  type = list
  description = "Uplink Left Segment VLANs"
  default = ["240"]
}

# T0 GW Interfaces
# !!! the IP is included for use in BGP source address, I'd like to find a better way to do that
# without repeating data. I couldn't get it to accept interface.ipaddresses as it hadn't been created yet.
variable "t0_edge1_left_name" {default = "edge1-left"}
variable "t0_edge1_left_ip" {default = "192.168.240.11"}
variable "t0_edge1_left_subnets" {
  type = list
  default = ["192.168.240.11/24"]
}
variable "t0_edge1_right_name" {default = "edge1-right"}
variable "t0_edge1_right_ip" {default = "192.168.250.11"}
variable "t0_edge1_right_subnets" {
  type = list
  default = ["192.168.250.11/24"]
}
variable "t0_edge2_left_name" {default = "edge2-left"}
variable "t0_edge2_left_ip" {default = "192.168.240.12"}
variable "t0_edge2_left_subnets" {
  type = list
  default = ["192.168.240.12/24"]
}
variable "t0_edge2_right_name" {default = "edge2-right"}
variable "t0_edge2_right_ip" {default = "192.168.250.12"}
variable "t0_edge2_right_subnets" {
  type = list
  default = ["192.168.250.12/24"]
}

# T0 BGP Configuration
variable "t0_bgp_local_asn" {default ="100"}
variable "t0_bgp_remote_asn" {default ="200"}

variable "t0_bgp_neighbor_left" {default = "BGP Neighbor Left"}
variable "t0_bgp_neighbor_left_ip" {default = "192.168.240.1"}

variable "t0_bgp_neighbor_right" {default = "BGP Neighbor Right"}
variable "t0_bgp_neighbor_right_ip" {default = "192.168.240.1"}


#variable "vsphere_rs_vars" {
#  type = map
#  description = "vSphere vars for Resources"
#  default = {
#    vm = "VM_name"
#  }
#}

variable "dns_server_list" {
    type = list
    description = "DNS Servers"
  default = ["192.168.110.0"]
}

variable "ip_set" {
  type = string
  description = "List of ip addresses that will be add in the IP-SET to allow communication to all VMs"
  default = "192.168.110.10"
}

variable "app_listen_port" {
  type = string
  description = "TCP Port the App server listens on"
  default = "8443"
}

#variable "db_user" {
#    type = string
#    description = "DB Details"
#}
#
#variable "db_pass" {
#    type = string
#    description = "DB Details"
#}
#
#variable "db_name" {
#    type = string
#    description = "DB Details"
#}


# Variables for VM deployment

#variable "web" {
#    type = map
#    description = "NSX vars for the resources"
#}
#variable "app" {
#    type = map
#    description = "NSX vars for the resources"
#}
#variable "db" {
#    type = map
#    description = "NSX vars for the resources"
#}

#
#db_user = "medicalappuser" # Database details
#db_name = "medicalapp"
#db_pass = "VMware1!"
#
#web = {
#    ip = "10.29.15.210"
#    gw = "10.29.15.209"
#    mask = "28"
#    nat_ip = "" # If the ip above is routable and has internet access you can leave the NAT IP blank
#    vm_name = "web"
#    domain = "yasen.local"
#    user = "root" # Credentails to access the VM
#    pass = "VMware1!"
#}
#
#app = {
#    ip = "192.168.245.21" # If this IP is not routable and has no internet access you need to condigure a NAT IP below
#    gw = "192.168.245.1"
#    mask = "24"
#    nat_ip = "10.29.15.229"
#    vm_name = "app"
#    domain = "yasen.local"
#    user = "root"
#    pass = "VMware1!"
#}
#
#db = {
#    ip = "192.168.247.21"
#    gw = "192.168.247.1"
#    mask = "24"
#    nat_ip = "10.29.15.228"
#    vm_name = "db"
#    domain = "yasen.local"
#    user = "root"
#    pass = "VMware1!"
#}

