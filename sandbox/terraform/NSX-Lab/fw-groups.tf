
# Create a Security Group, using the tag specified in the terraform.tfvars file
resource "nsxt_policy_group" "tf-all" {
  description  = "NSGroup provisioned by Terraform"
  display_name = "tf-all"
  criteria {
      condition {
        member_type = "VirtualMachine"
        key = "Tag"
        operator = "EQUALS"
        value = "${var.nsx_tag_scope}|${var.nsx_tag}"
      }
  }
    tag {
	scope = "${var.nsx_tag_scope}"
	tag = "${var.nsx_tag}"
    }
}

# Create a security group with the IP of our Control Center VM
resource "nsxt_policy_group" "tf-ip-set" {
  description  = "Policy Group provisioned by Terraform"
  display_name = "tf-ip-set"
  criteria {
      ipaddress_expression {

        ip_addresses = ["${var.ip_set}"]
      }
  }
    tag {
	scope = "${var.nsx_tag_scope}"
	tag = "${var.nsx_tag}"
    }
}