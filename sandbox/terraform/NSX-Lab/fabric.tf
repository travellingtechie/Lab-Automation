#! fabric.tf
# For small Plans, put everything in fabric.tf, for larger plans, create separate files.

# Most Fabric Items aren't available in Terraform at this time, including:
# Transport Zones
# Edge Nodes/Edge Clusters
# Compute Manager
# Transport Nodes/Profiles

# Data Sources
# Create the data sources we will need to refer to



#data "vsphere_datacenter" "dc" {
#  name = "${var.vsphere["dc"]}"
#}




# Resources

# Create IP Pool
#resource "nsxt_ip_pool" "ip_pool" {
#  description  = "ip_pool provisioned by Terraform"
#  display_name = "ip_pool"
#
#  tag {
#    scope = "color"
#    tag   = "red"
#  }
#
#  subnet {
#    allocation_ranges = ["2.1.1.1-2.1.1.11", "2.1.1.21-2.1.1.100"]
#    cidr              = "2.1.1.0/24"
#    gateway_ip        = "2.1.1.12"
#    dns_suffix        = "abc"
#    dns_nameservers   = ["33.33.33.33"]
#  }
#}