variable "key_name" {}
variable "instype" {
    default = "t2.micro"
}
variable "path_to_file" { default = "./zookeeper.sh"}
variable "subnet_id" { type = "list" }
variable "puppetmaster_dns" {}
variable "environment" {}
variable "puppet_ip" {}
variable "sec_group" {}
