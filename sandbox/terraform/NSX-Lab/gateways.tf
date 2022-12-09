# Gateway Creation

# Data Sources

#data "nsxt_policy_tier0_gateway" "tier0_router" {
#  display_name = "${var.nsx_data_vars["t0_router_name"]}"
#}

# Edge Cluster
data "nsxt_policy_edge_cluster" "edge_cluster1" {
  display_name = "${var.edge_cluster}"
}
data "nsxt_policy_edge_node" "edge_node_1" {
  display_name = "${var.edge_node_1}"
  edge_cluster_path = data.nsxt_policy_edge_cluster.edge_cluster1.path
}
data "nsxt_policy_edge_node" "edge_node_2" {
  display_name = "${var.edge_node_2}"
  edge_cluster_path = data.nsxt_policy_edge_cluster.edge_cluster1.path
}

# Uplink VLAN Transport Zone
data "nsxt_policy_transport_zone" "vlantz" {
  transport_type = "VLAN_BACKED"
  display_name = "${var.uplink_vlan_tz}"
}


# Resources


# Deploy T0 Gateway

# Create VLAN segments for uplinks
resource "nsxt_policy_vlan_segment" "vlan_left_seg" {
  display_name        = "${var.vlan_left_seg}"
  description         = "T0GW Left Uplink Segment"
  transport_zone_path = data.nsxt_policy_transport_zone.vlantz.path
  vlan_ids            = "${var.vlans_left_seg}"
  tag {
	scope = "${var.nsx_tag_scope}"
	tag = "${var.nsx_tag}"
  }
}
resource "nsxt_policy_vlan_segment" "vlan_right_seg" {
  display_name        = "${var.vlan_right_seg}"
  description         = "T0GW Right Uplink Segment"
  transport_zone_path = data.nsxt_policy_transport_zone.vlantz.path
  vlan_ids            = "${var.vlans_right_seg}"
  tag {
	scope = "${var.nsx_tag_scope}"
	tag = "${var.nsx_tag}"
  }
}

# Tier 0 Gateway
resource "nsxt_policy_tier0_gateway" "tier0_gw" {
  description                 = "Tier1 router provisioned by Terraform"
  display_name                = "${var.t0_gw_name}"
  failover_mode               = "PREEMPTIVE"
  ha_mode                     = "ACTIVE_STANDBY"
  edge_cluster_path           = "${data.nsxt_policy_edge_cluster.edge_cluster1.path}"

  tag {
	scope = "${var.nsx_tag_scope}"
	tag = "${var.nsx_tag}"
  }
}

# Tier 0 Gateway Interfaces
resource "nsxt_policy_tier0_gateway_interface" "T0_edge1_left" {
  display_name           = "${var.t0_edge1_left_name}"
  description            = "Edge Node 1 Left"
  type                   = "EXTERNAL"
  gateway_path           = nsxt_policy_tier0_gateway.tier0_gw.path
  segment_path           = nsxt_policy_vlan_segment.vlan_left_seg.path
  edge_node_path         = data.nsxt_policy_edge_node.edge_node_1.path
  subnets                = "${var.t0_edge1_left_subnets}"
  mtu                    = 1500
  tag {
	scope = "${var.nsx_tag_scope}"
	tag = "${var.nsx_tag}"
  }
}

resource "nsxt_policy_tier0_gateway_interface" "T0_edge1_right" {
  display_name           = "${var.t0_edge1_right_name}"
  description            = "Edge Node 1 Right"
  type                   = "EXTERNAL"
  gateway_path           = nsxt_policy_tier0_gateway.tier0_gw.path
  segment_path           = nsxt_policy_vlan_segment.vlan_right_seg.path
  edge_node_path         = data.nsxt_policy_edge_node.edge_node_1.path
  subnets                = "${var.t0_edge1_right_subnets}"
  mtu                    = 1500
  tag {
	scope = "${var.nsx_tag_scope}"
	tag = "${var.nsx_tag}"
  }
}
resource "nsxt_policy_tier0_gateway_interface" "T0_edge2_left" {
  display_name           = "${var.t0_edge2_left_name}"
  description            = "Edge Node 2 Left"
  type                   = "EXTERNAL"
  gateway_path           = nsxt_policy_tier0_gateway.tier0_gw.path
  segment_path           = nsxt_policy_vlan_segment.vlan_left_seg.path
  edge_node_path         = data.nsxt_policy_edge_node.edge_node_2.path
  subnets                = "${var.t0_edge2_left_subnets}"
  mtu                    = 1500
  tag {
	scope = "${var.nsx_tag_scope}"
	tag = "${var.nsx_tag}"
  }
}
resource "nsxt_policy_tier0_gateway_interface" "T0_edge2_right" {
  display_name           = "${var.t0_edge2_right_name}"
  description            = "Edge Node 2 Right"
  type                   = "EXTERNAL"
  gateway_path           = nsxt_policy_tier0_gateway.tier0_gw.path
  segment_path           = nsxt_policy_vlan_segment.vlan_right_seg.path
  edge_node_path         = data.nsxt_policy_edge_node.edge_node_2.path
  subnets                = "${var.t0_edge2_right_subnets}"
  mtu                    = 1500
  tag {
	scope = "${var.nsx_tag_scope}"
	tag = "${var.nsx_tag}"
  }
}

# BGP Config
resource "nsxt_policy_bgp_config" "tier0_gw-bgp" {
  gateway_path = nsxt_policy_tier0_gateway.tier0_gw.path

  enabled               = true
  inter_sr_ibgp         = true
  local_as_num          = "${var.t0_bgp_local_asn}"
  graceful_restart_mode = "HELPER_ONLY"
}

resource "nsxt_policy_bgp_neighbor" "bgp_neighbor_left" {
  display_name          = "${var.t0_bgp_neighbor_left}"
  description           = "BGP Neighbor Left"
  depends_on = [
    nsxt_policy_tier0_gateway_interface.T0_edge1_left,
    nsxt_policy_tier0_gateway_interface.T0_edge2_left
  ]
  bgp_path              = nsxt_policy_bgp_config.tier0_gw-bgp.path
  allow_as_in           = true
  graceful_restart_mode = "HELPER_ONLY"
  hold_down_time        = 300
  keep_alive_time       = 100
  neighbor_address      = "${var.t0_bgp_neighbor_left_ip}"
  remote_as_num         = "${var.t0_bgp_remote_asn}"
  source_addresses      = [
    "${var.t0_edge1_left_ip}",
    "${var.t0_edge2_left_ip}"
  ]

  bfd_config {
    enabled  = true
  }
}

resource "nsxt_policy_bgp_neighbor" "bgp_neighbor_right" {
  display_name          = "${var.t0_bgp_neighbor_right}"
  description           = "BGP Neighbor Right"
  depends_on = [
    nsxt_policy_tier0_gateway_interface.T0_edge1_right,
    nsxt_policy_tier0_gateway_interface.T0_edge2_right
  ]
  bgp_path              = nsxt_policy_bgp_config.tier0_gw-bgp.path
  allow_as_in           = true
  graceful_restart_mode = "HELPER_ONLY"
  hold_down_time        = 300
  keep_alive_time       = 100
  neighbor_address      = "${var.t0_bgp_neighbor_right_ip}"
  remote_as_num         = "${var.t0_bgp_remote_asn}"
  source_addresses      = [
    "${var.t0_edge1_right_ip}",
    "${var.t0_edge2_right_ip}"
  ]

  bfd_config {
    enabled  = true
  }
}


# Create T1 router
resource "nsxt_policy_tier1_gateway" "tier1_gw" {
  description                 = "Tier1 router provisioned by Terraform"
  display_name                = "${var.t1_gw_name}"
  failover_mode               = "PREEMPTIVE"
  edge_cluster_path            = "${data.nsxt_policy_edge_cluster.edge_cluster1.path}"
  tier0_path                  = nsxt_policy_tier0_gateway.tier0_gw.path
  route_advertisement_types  = ["TIER1_STATIC_ROUTES","TIER1_CONNECTED","TIER1_NAT"]
    tag {
	scope = "${var.nsx_tag_scope}"
	tag = "${var.nsx_tag}"
    }
}


