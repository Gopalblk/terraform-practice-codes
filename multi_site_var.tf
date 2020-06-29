variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
}

variable "admin_username" {
    type = "string"
    description = "Administrator user name for virtual machine"
}

variable "admin_password" {
    type = "string"
    description = "Password must meet Azure complexity requirements"
}

variable "subnet_names" {
  type    = list(string)
  default = ["web", "db"]
}

variable "location" {
  default = [
    "eastus",
    "centralus",
  ]
}

variable "vnet_address_space" {
  default = [
    "10.0.0.0/16",
    "10.1.0.0/16",
  ]
}

variable "sku" {
    default = {
        centralus = "16.04-LTS"
        eastus = "18.04-LTS"
    }
}
