# Create Web Tier NSX Segment

# Data Sources

# Transport Zone used in Segments
data "nsxt_policy_transport_zone" "overlay_tz" {
    display_name = "${var.transport_zone}"
}

# DHCP Server used by Segments
#data "nsxt_policy_dhcp_server" "dhcp_server" {
#  display_name = "${var.nsx_data_vars["dhcp_server"]}"
#}

# Resources
resource "nsxt_policy_segment" "tf-web" {
    description = "LS created by Terraform"
    display_name = "tf-web-tier"
    connectivity_path   = nsxt_policy_tier1_gateway.tier1_gw.path
    transport_zone_path = "${data.nsxt_policy_transport_zone.overlay_tz.path}"


  subnet {
    cidr        = "10.100.2.1/24"
#    dhcp_ranges = ["10.100.2.100-10.100.2.160"]
#    dhcp_config_path = nsxt_policy_dhcp_server.dhcp_server.path
    }

    tag {
	scope = "${var.nsx_tag_scope}"
	tag = "${var.nsx_tag}"
    }
    tag {
	scope = "tier"
	tag = "web"
    }
}