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
    source = "https://cloud.debian.org/images/cloud/trixie/daily/latest/debian-13-genericcloud-amd64-daily.qcow2"
    type   = "qcow2"
  }
}

variable "cluster_size" {
  description = "Number of VM instances to provision."
  type        = number
  default     = 1
}

variable "vm" {
  description = "VM hardware specs"
  type        = map(any)
  default = {
    arch      = "x86_64"
    cpu_mode  = "host-passthrough"
    type      = "kvm"
    cores     = 4
    memory    = 4096
    disk_size = 5368709120
  }
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

# Use ens3 for Debian based distros, eth0 for Alpine
variable "interface_name" {
  description = "Network interface name"
  type        = string
  default     = "ens3"
}

# Only needed for distros that dont generate /etc/resolv.conf from /etc/network/interfaces (e.g. Alpine)
variable "create_resolve_conf" {
  description = "Create /etc/resolv.conf"
  type        = bool
  default     = false
}

# OS packages to install
variable "os_packages" {
  description = "OS packages to install during VM creation"
  type        = list(string)
  default = [
    "lsb-release",
    "qemu-guest-agent"
  ]
}

# User defined variables set in [users].tfvars
variable "users" {
  description = "Users to create"
  type        = list(any)
  default = [
    {
      name     = ""
      password = ""
      ssh_keys = []
      shell    = ""
      groups   = []
      sudo     = false
    }
  ]
}
