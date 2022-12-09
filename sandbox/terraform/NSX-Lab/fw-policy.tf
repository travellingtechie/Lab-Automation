# Create a Firewall Policy and Rules

# Data Sources

# Create data sources for Services that we need to create FW rules
data "nsxt_policy_service" "https" {
  display_name = "HTTPS"
}

data "nsxt_policy_service" "mysql" {
  display_name = "MySQL"
}

data "nsxt_policy_service" "ssh" {
  display_name = "SSH"
}



#Resources

resource "nsxt_policy_security_policy" "tf_policy" {
  description  = "FS provisioned by Terraform"
  display_name = "Terraform Demo FW Section"
  category     = "Application"
  scope        = [nsxt_policy_group.tf-all.path]
  tag {
    scope = "${var.nsx_tag_scope}"
    tag   = "${var.nsx_tag}"
  }
  rule {
    display_name       = "Allow HTTPS"
    description        = "Ingress HTTPS rule"
    logged             = false
    destination_groups = [nsxt_policy_group.tf-all.path]
    services           = [data.nsxt_policy_service.https.path]
    action             = "ALLOW"
  }
  rule {
    display_name       = "Allow SSH"
    description        = "Ingress SSH rule"
    logged             = false
    source_groups      = [nsxt_policy_group.tf-ip-set.path]
    destination_groups = [nsxt_policy_group.tf-all.path]
    services           = [data.nsxt_policy_service.ssh.path]
    action             = "ALLOW"
  }
  rule {
    display_name  = "Allow Egress"
    description   = "TF Egress Rule"
    logged        = false
    source_groups = [nsxt_policy_group.tf-all.path]
    action        = "ALLOW"
  }
  rule {
    display_name       = "Reject Ingress"
    description        = "TF Ingress Rule"
    logged             = true
    destination_groups = [nsxt_policy_group.tf-all.path]
    action             = "REJECT"
  }
}