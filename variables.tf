# Configuration
variable "qemu_uri" {
  description = "Qemu connection URI"
  type        = string
  default     = "qemu:///system"
}

variable "debian_cloud_image" {
  description = "VM base image"
  default = {
    #source = "https://cloud.debian.org/images/cloud/sid/daily/latest/debian-sid-genericcloud-amd64-daily.qcow2"
    source = "https://cloud.debian.org/images/cloud/bullseye/daily/latest/debian-11-genericcloud-amd64-daily.qcow2"
    #source = "/var/lib/libvirt/images/debian-11-genericcloud-amd64-daily.qcow2"
    type   = "qcow2"
  }
}

variable "net_config" {
  description = "local network config"
  default = {
    name           = "debian-network"
    mode           = "nat"
    domain         = "debian-net"
    search_domains = ["debian-net"]
    subnets        = ["10.1.2.0/24"]
    gateway        = "10.1.2.1"
    dns_servers    = ["10.1.2.1"]
    cidr           = "24"
    start_addr     = "10"
  }
}

variable "cluster_size" {
  description = "Number of Debian instances to provision."
  type        = number
  default     = 2
}

variable "debian_vm" {
  description = "Debian VM hardware specs"
  type        = map(number)
  default = {
    cores     = 4
    memory    = 4096
    disk_size = 5368709120
  }
}

variable "os_packages" {
  description = "OS packages to install"
  type        = list(string)
  default = [
    "apt-transport-https",
    "docker.io"
  ]
}

# User defined variables found in [user-name].tfvars
variable "user" {
  description = "The name of the user to create"
  type        = string
  default     = ""
}

variable "password" {
  description = "Users password hash"
  type        = string
  default     = ""
}

variable "ssh_keys" {
  description = "Users public SSH keys"
  type        = list(string)
  default     = [""]
}