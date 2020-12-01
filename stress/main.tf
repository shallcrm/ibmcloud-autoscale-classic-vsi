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

# package_upgrade not set to true. Avoids long execution time in demo mode. 
# base64_encode and gzip set to false as not supported by IBM Cloud

data "template_cloudinit_config" "app_userdata" {
  base64_encode = false
  gzip          = false

  part {
    content = <<EOF
#cloud-config
packages:
  - stress
  - htop
  - mc
# Update command prompt for selected users
runcmd:
  - sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' /root/.bashrc
# Send final message that all steps are complete
final_message: "The system is finally up, after $UPTIME seconds"
EOF

  }
}


########################################################
# Create Auto Scale Group and Policies 
########################################################

resource "ibm_compute_autoscale_group" "stress_scale_group" {
  name                       = "shallcrm_stress"
  regional_group             = var.regional_group_name
  minimum_member_count       = 1
  maximum_member_count       = 5
  cooldown                   = 30
  termination_policy         = "CLOSEST_TO_NEXT_CHARGE"
  virtual_guest_member_template {
    hostname                 = "stress"
    domain                   = var.dns_domain
    os_reference_code        = var.osrefcode
    datacenter               = var.datacenter1
    hourly_billing           = true                     //  Hourly billing rather than monthly
    cores                    = 1                        //  Number of cores
    memory                   = 1024                     //  Amount of RAM (MB)
    disks                    = [25]                     //  Disk size(s) (GB)
    local_disk               = false                    //  Use SAN rather than local disk
    network_speed            = 100                      //  100 Mbps LAN
    private_network_only     = false                    //  Both public and private network interfaces
    ssh_key_ids              = [data.ibm_compute_ssh_key.ssh_key.id]                   //  ID of the existing ssh key we are using
    user_metadata            = data.template_cloudinit_config.app_userdata.rendered    //  Cloud-init data
  }
}

resource "ibm_compute_autoscale_policy" "stress_scale_policy_1" {
  name                       = "stress_scale_up"
  scale_type                 = "RELATIVE"
  scale_amount               = 1
  cooldown                   = 30
  scale_group_id             = ibm_compute_autoscale_group.stress_scale_group.id
  triggers {
    type = "RESOURCE_USE"
      watches {
        metric = "host.cpu.percent"
        operator = ">"
        value = "80"
        period = 120
      }
  }
}

resource "ibm_compute_autoscale_policy" "stress_scale_policy_2" {
  name                       = "stress_scale_down"
  scale_type                 = "RELATIVE"
  scale_amount               = -1          
  cooldown                   = 30
  scale_group_id             = ibm_compute_autoscale_group.stress_scale_group.id
  triggers {
    type = "RESOURCE_USE"
      watches {
        metric = "host.cpu.percent"
        operator = "<"
        value = "20"
        period = 120
      }
  }
}