# Derived from https://blogs.vmware.com/networkvirtualization/2018/04/nsx-t-automation-with-terraform.html


# Create T1 router
resource "nsxt_policy_tier1_gateway" "tier1_gw" {
  description                 = "Tier1 router provisioned by Terraform"
  display_name                = "${var.nsx_rs_vars["t1_router_name"]}"
  failover_mode               = "PREEMPTIVE"
  edge_cluster_path            = "${data.nsxt_policy_edge_cluster.edge_cluster1.path}"
  tier0_path                  = data.nsxt_policy_tier0_gateway.tier0_router.path
  route_advertisement_types  = ["TIER1_STATIC_ROUTES","TIER1_CONNECTED","TIER1_NAT"]
    tag {
	scope = "${var.nsx_tag_scope}"
	tag = "${var.nsx_tag}"
    }
}

# Create Web Tier NSX Segment
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

#
## Create a Firewall Policy and Rules

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
    display_name = "Allow HTTPS"
    description  = "Ingress HTTPS rule"
    logged       = false
    destination_groups = [nsxt_policy_group.tf-all.path]
    services = [data.nsxt_policy_service.https.path]
    action       = "ALLOW"
  }
  rule {
    display_name = "Allow SSH"
    description  = "Ingress SSH rule"
    logged       = false
    source_groups = [nsxt_policy_group.tf-ip-set.path]
    destination_groups = [nsxt_policy_group.tf-all.path]
    services = [data.nsxt_policy_service.ssh.path]
    action       = "ALLOW"
  }
  rule {
    display_name = "Allow Egress"
    description  = "TF Egress Rule"
    logged       = false
    source_groups = [nsxt_policy_group.tf-all.path]
    action       = "ALLOW"
  }
  rule {
    display_name = "Reject Ingress"
    description  = "TF Ingress Rule"
    logged       = true
    destination_groups = [nsxt_policy_group.tf-all.path]
    action       = "REJECT"
  }

}
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

## Next step is to use the vSphere provider to clone a VM
# Then apply a configuration via cloud init or saltstack


## Clone a VM from the template and attach it to the newly created logical switch
#resource "vsphere_virtual_machine" "appvm" {
#    name             = "${var.app["vm_name"]}"
#    depends_on = ["nsxt_logical_switch.app"]
#    resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
#    datastore_id     = "${data.vsphere_datastore.datastore.id}"
#    num_cpus = 1
#    memory   = 1024
#    guest_id = "${data.vsphere_virtual_machine.template.guest_id}"
#    scsi_type = "${data.vsphere_virtual_machine.template.scsi_type}"
#    # Attach the VM to the network data source that refers to the newly created logical switch
#    network_interface {
#      network_id = "${data.vsphere_network.terraform_app.id}"
#    }
#    disk {
#	label = "${var.app["vm_name"]}.vmdk"
#        size = 16
#        thin_provisioned = true
#    }
#    clone {
#	template_uuid = "${data.vsphere_virtual_machine.template.id}"
#
#	# Guest customization to supply hostname and ip addresses to the guest
#	customize {
#	    linux_options {
#		host_name = "${var.app["vm_name"]}"
#		domain = "${var.app["domain"]}"
#	    }
#	    network_interface {
#		ipv4_address = "${var.app["ip"]}"
#		ipv4_netmask = "${var.app["mask"]}"
#		dns_server_list = "${var.dns_server_list}"
#		dns_domain = "${var.app["domain"]}"
#	    }
#	    ipv4_gateway = "${var.app["gw"]}"
#	}
#    }
#    connection {
#	type = "ssh",
#	agent = "false"
#	host = "${var.app["nat_ip"] != "" ? var.app["nat_ip"] : var.app["ip"]}"
#	user = "${var.app["user"]}"
#	password = "${var.app["pass"]}"
#	script_path = "/root/tf.sh"
#    }
#    provisioner "remote-exec" {
#	inline = [
#	    "echo 'nameserver ${var.dns_server_list[0]}' >> /etc/resolv.conf", # By some reason guest customization didnt configure DNS, so this is a workaround
#	    "rm -f /etc/yum.repos.d/vmware-tools.repo",
#	    "/usr/bin/systemctl stop firewalld",
#	    "/usr/bin/systemctl disable firewalld",
#	    "/usr/bin/yum makecache",
#	    "git clone https://github.com/yasensim/demo-three-tier-app.git",
#	    "cp demo-three-tier-app/nsxapp.tar.gz /opt/",
#	    "tar -xvzf /opt/nsxapp.tar.gz -C /opt/",
#	    "/usr/bin/yum install httpd -y",
#	    "if [ -r /etc/httpd/conf.d/ssl.conf ]; then mv /etc/httpd/conf.d/ssl.conf /etc/httpd/conf.d/ssl.conf.disabled ; fi",
#	    "/usr/bin/systemctl enable httpd.service",
#	    "/usr/bin/systemctl start httpd.service",
#	    "/usr/bin/yum install php php-mysql mariadb -y",
#	    "/usr/sbin/setsebool -P httpd_can_network_connect=1",
#	    "/usr/bin/systemctl restart httpd.service",
#	    "/usr/bin/yum install mod_ssl -y",
#	    "/usr/bin/mkdir -p /var/www/html2",
#	    "/usr/bin/cp -a /opt/nsx/medicalapp/* /var/www/html2",
#
#	    # ssl certs
#	    "/usr/bin/cp -a /opt/nsx/cert.pem /etc/ssl/cert.pem",
#	    "/usr/bin/cp -a /opt/nsx/cert.key /etc/ssl/cert.key",
#
#	    # app configuration
#	    "/bin/sed -i 's/MEDAPP_DB_USER/${var.db_user}/g' /var/www/html2/index.php",
#	    "/bin/sed -i 's/MEDAPP_DB_PASS/${var.db_pass}/g' /var/www/html2/index.php",
#	    "/bin/sed -i 's/MEDAPP_DB_HOST/${var.db["ip"]}/g' /var/www/html2/index.php",
#	    "/bin/sed -i 's/MEDAPP_DB_NAME/${var.db_name}/g' /var/www/html2/index.php",
#
#	    # httpd configuration
#	    "/usr/bin/echo 'ServerName appserver.yasen.local' > /etc/httpd/conf.d/ssl.conf",
#	    "/usr/bin/echo 'Listen 8443' >> /etc/httpd/conf.d/ssl.conf",
#	    "/usr/bin/echo '' >> /etc/httpd/conf.d/ssl.conf",
#	    "/usr/bin/echo 'SSLCertificateFile /etc/ssl/cert.pem' >> /etc/httpd/conf.d/ssl.conf",
#	    "/usr/bin/echo 'SSLCertificateKeyFile /etc/ssl/cert.key' >> /etc/httpd/conf.d/ssl.conf",
#	    "/usr/bin/echo '' >> /etc/httpd/conf.d/ssl.conf",
#	    "/usr/bin/echo '<VirtualHost _default_:${var.app_listen_port}>' >> /etc/httpd/conf.d/ssl.conf",
#	    "/usr/bin/echo '  SSLEngine on' >> /etc/httpd/conf.d/ssl.conf",
#	    "/usr/bin/echo '  DocumentRoot \"/var/www/html2\"' >> /etc/httpd/conf.d/ssl.conf",
#	    "/usr/bin/echo '  <Directory \"/var/www/html\">' >> /etc/httpd/conf.d/ssl.conf",
#	    "/usr/bin/echo '    Options Indexes FollowSymLinks' >> /etc/httpd/conf.d/ssl.conf",
#	    "/usr/bin/echo '    AllowOverride None' >> /etc/httpd/conf.d/ssl.conf",
#	    "/usr/bin/echo '    Require all granted' >> /etc/httpd/conf.d/ssl.conf",
#	    "/usr/bin/echo '  </Directory>' >> /etc/httpd/conf.d/ssl.conf",
#	    "/usr/bin/echo '</VirtualHost>' >> /etc/httpd/conf.d/ssl.conf",
#	    "/usr/bin/systemctl stop httpd",
#	    "/usr/bin/systemctl start httpd"
#	]
#    }
#
#}
#
## Tag the newly created VM, so it will becaome a member of my NSGroup
## that way all fw rules we have defined earlier will be applied to it
#resource "nsxt_vm_tags" "vm1_tags" {
#    instance_id = "${vsphere_virtual_machine.appvm.id}"
#    tag {
#	scope = "${var.nsx_tag_scope}"
#	tag = "${var.nsx_tag}"
#    }
#    tag {
#	scope = "tier"
#	tag = "app"
#    }
#}
## Clone a VM from the template above and attach it to the newly created logical switch
#resource "vsphere_virtual_machine" "webvm" {
#    name             = "${var.web["vm_name"]}"
#    depends_on = ["nsxt_logical_switch.web"]
#    resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
#    datastore_id     = "${data.vsphere_datastore.datastore.id}"
#    num_cpus = 1
#    memory   = 1024
#    guest_id = "${data.vsphere_virtual_machine.template.guest_id}"
#    scsi_type = "${data.vsphere_virtual_machine.template.scsi_type}"
#    # Attach the VM to the network data source that refers to the newly created logical switch
#    network_interface {
#      network_id = "${data.vsphere_network.terraform_web.id}"
#    }
#    disk {
#	label = "${var.web["vm_name"]}.vmdk"
#        size = 16
#        thin_provisioned = true
#    }
#    clone {
#	template_uuid = "${data.vsphere_virtual_machine.template.id}"
#
#	# Guest customization to supply hostname and ip addresses to the guest
#	customize {
#	    linux_options {
#		host_name = "${var.web["vm_name"]}"
#		domain = "${var.web["domain"]}"
#	    }
#	    network_interface {
#		ipv4_address = "${var.web["ip"]}"
#		ipv4_netmask = "${var.web["mask"]}"
#		dns_server_list = "${var.dns_server_list}"
#		dns_domain = "${var.web["domain"]}"
#	    }
#	    ipv4_gateway = "${var.web["gw"]}"
#	}
#    }
#    connection {
#	type = "ssh",
#	agent = "false"
#	host = "${var.web["nat_ip"] != "" ? var.web["nat_ip"] : var.web["ip"]}"
#	user = "${var.web["user"]}"
#	password = "${var.web["pass"]}"
#	script_path = "/root/tf.sh"
#    }
#    provisioner "remote-exec" {
#	inline = [
#	    "echo 'nameserver ${var.dns_server_list[0]}' >> /etc/resolv.conf",
#	    "rm -f /etc/yum.repos.d/vmware-tools.repo",
#	    "/usr/bin/systemctl stop firewalld",
#	    "/usr/bin/systemctl disable firewalld",
#	    "/usr/bin/yum makecache",
#	    "/usr/bin/yum install epel-release -y",
#	    "/usr/bin/yum install nginx -y",
#	    "git clone https://github.com/yasensim/demo-three-tier-app.git",
#	    "cp demo-three-tier-app/nsxapp.tar.gz /opt/",
#	    "tar -xvzf /opt/nsxapp.tar.gz -C /opt/",
#	    "/bin/sed -i \"s/80 default_server/443 default_server/g\" /etc/nginx/nginx.conf",
#	    "/bin/sed -i 's/location \\//location \\/unuseful_location/g' /etc/nginx/nginx.conf",
#	    "/usr/bin/cp -a /opt/nsx/cert.pem /etc/ssl/cert.pem",
#	    "/usr/bin/cp -a /opt/nsx/cert.key /etc/ssl/cert.key",
#	    "/bin/sed -i 's/.*\\[::\\]/#&/g' /etc/nginx/nginx.conf",
#	    "/usr/bin/echo \"ssl on;\" > /etc/nginx/default.d/ssl.conf",
#	    "/usr/bin/echo \"ssl_certificate /etc/ssl/cert.pem;\" >> /etc/nginx/default.d/ssl.conf",
#	    "/usr/bin/echo \"ssl_certificate_key /etc/ssl/cert.key;\" >> /etc/nginx/default.d/ssl.conf",
#	    "/usr/bin/echo \"location / {\" >> /etc/nginx/default.d/ssl.conf",
#	    "/usr/bin/echo \"    proxy_pass https://${var.app["ip"]}:${var.app_listen_port};\" >> /etc/nginx/default.d/ssl.conf",
#	    "/usr/bin/echo \"}\" >> /etc/nginx/default.d/ssl.conf",
#	    "/usr/bin/systemctl enable nginx.service",
#	    "/usr/bin/systemctl start nginx"
#	]
#    }
#}
#
## Tag the newly created VM, so it will becaome a member of my NSGroup
## that way all fw rules we have defined earlier will be applied to it
#resource "nsxt_vm_tags" "vm2_tags" {
#    instance_id = "${vsphere_virtual_machine.webvm.id}"
#    tag {
#	scope = "${var.nsx_tag_scope}"
#	tag = "${var.nsx_tag}"
#    }
#    tag {
#	scope = "tier"
#	tag = "web"
#    }
#}
#
#
#
#
## Clone a VM from the template above and attach it to the newly created logical switch
#resource "vsphere_virtual_machine" "dbvm" {
#    name             = "${var.db["vm_name"]}"
#    depends_on = ["nsxt_logical_switch.db"]
#    resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
#    datastore_id     = "${data.vsphere_datastore.datastore.id}"
#    num_cpus = 1
#    memory   = 1024
#    guest_id = "${data.vsphere_virtual_machine.template.guest_id}"
#    scsi_type = "${data.vsphere_virtual_machine.template.scsi_type}"
#    # Attach the VM to the network data source that refers to the newly created logical switch
#    network_interface {
#      network_id = "${data.vsphere_network.terraform_db.id}"
#    }
#    disk {
#	label = "${var.db["vm_name"]}.vmdk"
#        size = 16
#        thin_provisioned = true
#    }
#    clone {
#	template_uuid = "${data.vsphere_virtual_machine.template.id}"
#
#	# Guest customization to supply hostname and ip addresses to the guest
#	customize {
#	    linux_options {
#		host_name = "${var.db["vm_name"]}"
#		domain = "${var.db["domain"]}"
#	    }
#	    network_interface {
#		ipv4_address = "${var.db["ip"]}"
#		ipv4_netmask = "${var.db["mask"]}"
#		dns_server_list = "${var.dns_server_list}"
#		dns_domain = "${var.db["domain"]}"
#	    }
#	    ipv4_gateway = "${var.db["gw"]}"
#	}
#    }
#    connection {
#	type = "ssh",
#	agent = "false"
#	host = "${var.db["nat_ip"] != "" ? var.db["nat_ip"] : var.db["ip"]}"
#	user = "${var.app["user"]}"
#	password = "${var.app["pass"]}"
#	script_path = "/root/tf.sh"
#    }
#    provisioner "remote-exec" {
#	inline = [
#	    "echo 'nameserver ${var.dns_server_list[0]}' >> /etc/resolv.conf",
#	    "rm -f /etc/yum.repos.d/vmware-tools.repo",
#	    "/usr/bin/systemctl stop firewalld",
#	    "/usr/bin/systemctl disable firewalld",
#	    "/usr/bin/yum makecache",
#	    "git clone https://github.com/yasensim/demo-three-tier-app.git",
#	    "cp demo-three-tier-app/nsxapp.tar.gz /opt/",
#	    "tar -xvzf /opt/nsxapp.tar.gz -C /opt/",
#	    "/usr/bin/yum install mariadb-server -y",
#	    "/sbin/chkconfig mariadb on",
#	    "/sbin/service mariadb start",
#	    "/bin/echo '[mysqld]' > /etc/my.cnf.d/skipdns.cnf",
#	    "/bin/echo 'skip-name-resolve' >> /etc/my.cnf.d/skipdns.cnf",
#	    "/usr/bin/mysql -e \"UPDATE mysql.user SET Password=PASSWORD('${var.db_pass}') WHERE User='root';\"",
#	    "/usr/bin/mysql -e \"DELETE FROM mysql.user WHERE User='';\"",
#	    "/usr/bin/mysql -e \"DROP DATABASE test;\"",
#	    "/usr/bin/mysql -e \"FLUSH PRIVILEGES;\"",
#	    "/bin/systemctl restart mariadb.service",
#	    "/usr/bin/mysql -e 'CREATE DATABASE ${var.db_name};' --user=root --password=${var.db_pass}",
#	    "/usr/bin/mysql -e \"CREATE USER '${var.db_user}'@'%';\" --user=root --password=${var.db_pass}",
#	    "/usr/bin/mysql -e \"SET PASSWORD FOR '${var.db_user}'@'%'=PASSWORD('${var.db_pass}');\" --user=root --password=${var.db_pass}",
#	    "/usr/bin/mysql -e \"GRANT ALL PRIVILEGES ON ${var.db_name}.* TO '${var.db_user}'@'%'IDENTIFIED BY '${var.db_pass}';\" --user=root --password=${var.db_pass}",
#	    "/usr/bin/mysql -e \"FLUSH PRIVILEGES;\" --user=root --password=${var.db_pass}",
#	    "/usr/bin/mysql --user=${var.db_user} --password=${var.db_pass} < /opt/nsx/medicalapp.sql ${var.db_name}"
#	]
#    }
#
#}
#
## Tag the newly created VM, so it will become a member of my NSGroup
## that way all fw rules we have defined earlier will be applied to it
#resource "nsxt_vm_tags" "vm3_tags" {
#    instance_id = "${vsphere_virtual_machine.dbvm.id}"
#    tag {
#	scope = "${var.nsx_tag_scope}"
#	tag = "${var.nsx_tag}"
#    }
#    tag {
#	scope = "tier"
#	tag = "db"
#    }
#}
