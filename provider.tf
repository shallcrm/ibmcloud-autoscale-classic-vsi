###################################
#### PROVIDER - Cloud provider ####
###################################

# IBM Cloud provider and credentials  (variables to be set externally using EXPORT commands or via IBM Schematics)
provider "ibm" {
  version               = ">= 1.9"                     //  Provider for Terraform 0.12+
  iaas_classic_username = var.iaas_classic_username    //  IBM Cloud Classic / SoftLayer user name
  iaas_classic_api_key  = var.iaas_classic_api_key     //  IBM Cloud Classic / SoftLayer API key
  ibmcloud_api_key      = var.ibmcloud_api_key         //  IBM Cloud API key
}

