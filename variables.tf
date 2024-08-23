variable "project" {
  description = "The project name smart wallet (sw)"
  default = "sw"
}
variable "environment" {
  description = "The environment to release"
  default = "dev"
}
variable "location" {
  description = "The location to deploy the resources"
  default = "East US 2"
}
variable "administrator-login" {
  description = "The administrator login for the Microsoft SQL Server"
  default = "sqladmin"
}
variable "administrator-login-password" {
  description = "The administrator login password for the Microsoft SQL Server"
  type = string
  sensitive = true
}
variable "tags" {
  description = "The tags to associate to the resources"
  default = {
    environment = "dev"
    project = "sw"
    created_by = "terraform"
  }
}
variable "my-ip" {
  description = "The IP address to allow in the firewall rules"
  default = "138.94.122.229"
}