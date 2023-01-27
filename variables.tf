# Configuration
variable "qemu_uri" {
  description = "Qemu connection URI"
  type        = string
  default     = "qemu:///system"
}

variable "vmname" {
  description = "The VM name prefix"
  type        = string
  default     = "debian"
}

variable "cloud_image" {
  description = "VM base image"
  type        = map(string)
  default = {
    # Debian
    #source = "https://cloud.debian.org/images/cloud/sid/daily/latest/debian-sid-genericcloud-amd64-daily.qcow2"
    source = "https://cloud.debian.org/images/cloud/bullseye/daily/latest/debian-11-genericcloud-amd64-daily.qcow2"
    type   = "qcow2"
    # Ubuntu 22.04
    #source = "https://cloud-images.ubuntu.com/daily/server/jammy/current/jammy-server-cloudimg-amd64.img"
    #type   = "raw"
  }
}

variable "cluster_size" {
  description = "Number of VM instances to provision."
  type        = number
  default     = 2
}

variable "vm" {
  description = "VM hardware specs"
  type        = map(number)
  default = {
    cores     = 4
    memory    = 4096
    disk_size = 5368709120
  }
}

variable "os_packages" {
  description = "OS packages to install during VM creation"
  type        = list(string)
  default = [
    "apt-transport-https",
    "docker.io"
  ]
}

variable "net_config" {
  description = "local network config"
  default = {
    name           = "vm-network"
    mode           = "nat"
    domain         = "vm-net"
    search_domains = ["vm-net"]
    subnets        = ["10.1.2.0/24"]
    gateway        = "10.1.2.1"
    dns_servers    = ["10.1.2.1"]
    cidr           = "24"
    start_addr     = "10"
  }
}

# User defined variables found in [user-name].tfvars
variable "users" {
  description = "Users to create"
  type        = list(any)
  default = [
    {
      name     = ""
      password = ""
      ssh_keys = ""
      shell    = ""
      sudo     = false
    }
  ]
}
