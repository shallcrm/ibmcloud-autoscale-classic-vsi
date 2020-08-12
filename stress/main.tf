###################################
#### MAIN - Main plan          ####
###################################


# Retrieve details of existing SSH keys that will be used to provision and access VMs
data "ibm_compute_ssh_key" "ssh_key" {
    label = var.classic_key_name
}


###########################################################
# Cloud-init data to customise VMs for web tier and db tier
###########################################################

# Cloud-init using cloud-config
# This configuration is designed to validate a fully working website has been created.

# commands are written within ''s. []s causes runcmd to fail on host
# manage_etc_hosts set to true to explicitly call attention to the fact that this
# is the default on IBM Cloud. /etc/hosts is refreshed at each reboot from
# /etc/cloud/templates/hosts.redhat.tmpl. 

# Install Apache web server, copy index.html to avoid 403 http code
# Record final msg in /var/log/cloud-init.log

# package_upgrade not set to true. Avoids long execution time in demo mode. 
# base64_encode and gzip set to false as not supported by IBM Cloud

data "template_cloudinit_config" "app_userdata" {
  base64_encode = false
  gzip          = false

  part {
    content = <<EOF
#cloud-config
manage_etc_hosts: true
package_upgrade: false
packages:
- stress
- htop
- mc
final_message: "The system is finally up, after $UPTIME seconds"
EOF

  }
}


########################################################
# Create VMs for app tier 
########################################################

resource "ibm_compute_vm_instance" "app1" {
  count             = var.vm_count_app
  os_reference_code = var.osrefcode

  # incrementally created hostnames
  hostname   = format("stress-%02d", count.index + 1)
  domain     = var.dns_domain
  datacenter = var.datacenter1

  hourly_billing = true                     //  Hourly billing rather than monthly
  transient      = true                     //  Transient VM (requires use of Flavor)

  #    flavor_key_name       = "C1_1X1X25"  //  Use Flavor key for Transient.  Use Cores + Memory + Disks for Standard
  #    cores                 = 1            //  Number of cores
  #    memory                = 1024         //  Amount of RAM (MB)
  #    disks                 = [25]         //  Disk size(s)

  flavor_key_name = "C1_1X1X25"             //  Using smallest flavor for testing

  local_disk = false                        //  Use SAN rather than local disk

  network_speed        = 100                //  100 Mbps LAN
  private_network_only = false              //  Both public and private network interfaces

  ssh_key_ids = [data.ibm_compute_ssh_key.ssh_key.id]                     //  ID of the existing ssh key we are using

  user_metadata = data.template_cloudinit_config.app_userdata.rendered    //  Cloudinit data

  tags = ["group:stresstest", "owner:shallcrm"]
}


