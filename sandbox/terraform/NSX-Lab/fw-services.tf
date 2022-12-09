# Create custom Service for App that listens on port specified in terraform.tfvars
resource "nsxt_policy_service" "app" {
  description       = "L4 Port range provisioned by Terraform"
  display_name      = "App Service"
  l4_port_set_entry {
    display_name      = "TCP${var.app_listen_port}"
    description       = "TCP port ${var.app_listen_port} entry"
    protocol          = "TCP"
    destination_ports = ["${var.app_listen_port}"]
  }
    tag {
	scope = "${var.nsx_tag_scope}"
	tag = "${var.nsx_tag}"
    }
}
