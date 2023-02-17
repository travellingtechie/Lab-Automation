# Create the data sources we will need to refer to

data "nsxt_policy_transport_zone" "overlay_tz" {
    display_name = "${var.nsx_data_vars["transport_zone"]}"
}

data "nsxt_policy_tier0_gateway" "tier0_router" {
  display_name = "${var.nsx_data_vars["t0_router_name"]}"
}

data "nsxt_policy_edge_cluster" "edge_cluster1" {
    display_name = "${var.nsx_data_vars["edge_cluster"]}"
}

# Create data sources for some NSServices that we need to create FW rules
data "nsxt_policy_service" "https" {
  display_name = "HTTPS"
}

data "nsxt_policy_service" "mysql" {
  display_name = "MySQL"
}

data "nsxt_policy_service" "ssh" {
  display_name = "SSH"
}
data "nsxt_policy_vm" "web-02a" {
  display_name = "web-02a"
}
#data "vsphere_datacenter" "dc" {
#  name = "${var.vsphere["dc"]}"
#}


## Data source for the logical switch we created earlier
## we need that as we cannot refer directly to the logical switch from the vm resource below
#data "vsphere_network" "terraform_web" {
#    name = "${nsxt_logical_switch.web.display_name}"
#    datacenter_id = "${data.vsphere_datacenter.dc.id}"
#    depends_on = ["nsxt_logical_switch.web"]
#}
#data "vsphere_network" "terraform_app" {
#    name = "${nsxt_logical_switch.app.display_name}"
#    datacenter_id = "${data.vsphere_datacenter.dc.id}"
#    depends_on = ["nsxt_logical_switch.app"]
#}
#data "vsphere_network" "terraform_db" {
#    name = "${nsxt_logical_switch.db.display_name}"
#    datacenter_id = "${data.vsphere_datacenter.dc.id}"
#    depends_on = ["nsxt_logical_switch.db"]
#}
#
#
#
## Datastore data source
#data "vsphere_datastore" "datastore" {
#  name          = "${var.vsphere["datastore"]}"
#  datacenter_id = "${data.vsphere_datacenter.dc.id}"
#}
#
## data source for my cluster's default resource pool
#data "vsphere_resource_pool" "pool" {
#  name          = "${var.vsphere["resource_pool"]}"
#  datacenter_id = "${data.vsphere_datacenter.dc.id}"
#}
#
## Data source for the template I am going to use to clone my VM from
#data "vsphere_virtual_machine" "template" {
#    name = "${var.vsphere["vm_template"]}"
#    datacenter_id = "${data.vsphere_datacenter.dc.id}"
#}
#
#data "nsxt_policy_dhcp_server" "dhcp_server" {
#  display_name = "${var.nsx_data_vars["dhcp_server"]}"
#}