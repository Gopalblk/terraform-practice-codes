variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
}

variable "sku" {
    default = {
        westus = "16.04-LTS"
        eastus = "18.04-LTS"
    }
}

variable "admin_username" {
    type = "string"
    description = "Administrator user name for virtual machine"
}

variable "admin_password" {
    type = "string"
    description = "Password must meet Azure complexity requirements"
}
