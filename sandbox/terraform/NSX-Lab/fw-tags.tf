# Create VM tags

resource "nsxt_policy_vm_tags" "web02a_tags" {
  instance_id = data.nsxt_policy_vm.web-02a.id
  tag {
	scope = "${var.nsx_tag_scope}"
	tag = "${var.nsx_tag}"
    }
    tag {
	scope = "tier"
	tag = "web"
    }
}