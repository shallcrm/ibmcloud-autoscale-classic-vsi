####################################################################
####  VARIABLES - Define the variables we will use in this plan ####
####################################################################

#### IBM Cloud Access Credentials #####
# Note:  The values of these variables should be set either by exporting environment variables
#        or by setting the variables in a separate .tfvars file
#        These credentials MUST NOT be published on git or any other public repository
variable "iaas_classic_username" { 
    description = "IBM Cloud Classic Infrastructure / SoftLayer user name"
    default = "" 
}
variable "iaas_classic_api_key" {
    description = "IBM Cloud Classic Infrastructure / SoftLayer API key"
    default = "" 
}
variable "ibmcloud_api_key" {
    description = "IBM Cloud Platform / Bluemix API key"
    default = "" 
}

##### IBM Cloud SSH Key Names ######
variable "classic_key_name" {
  description = "Name or reference of SSH key to provision classic VSI instances with"
  default = "Michael Shallcross SSH Key 2"
}



##### IBM Cloud VSI Details ######

variable "dns_domain" {
  description = "Web server domain name"
  default     = "east.csc.cloud.ibm"
}

variable "osrefcode" {
  default = "CENTOS_7_64"
}

variable "vm_count_lb" {
  description = "Number of VMs to be provisioned for load balancers"
  default     = "0"
}

variable "vm_count_app" {
  description = "Number of VMs to be provisioned for webservers"
  default     = "2"
}

variable "vm_count_db" {
  description = "Number of VMs to be provisioned for databases"
  default     = "1"
}

variable "datacenter1" {
  default = "tok05"
}

##### IBM Cloud Load Balancer Details ######

variable "lb_name" {
  default = "web-lb"
}

# variable "lb_notes" {
#   default = "DNS name for IBM Cloud Load Balancers"
# }

variable "lb_method" {
  default = "round_robin"
}

