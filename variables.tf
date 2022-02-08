# Configuration
variable "qemu_uri" {
  description = "Qemu connection URI"
  type        = string
  default     = "qemu:///system"
}

variable "net_config" {
  description = "lLcal network config"
  default = {
    domain         = "debian-net"
    search_domains = ["debian-net"]
    subnets        = ["10.1.2.0/24"]
    gateway        = "10.1.2.1"
    dns_servers    = ["10.1.2.1"]
  }
}

variable "ips" {
  description = "List of static IPs"
  type        = map(string)
  default = {
    0 = "10.1.2.10/24"
    1 = "10.1.2.11/24"
    2 = "10.1.2.12/24"
    3 = "10.1.2.13/24"
    4 = "10.1.2.14/24"
    5 = "10.1.2.15/24"
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

variable "ssh_key" {
  description = "Users public SSH key"
  type        = string
  default     = ""
}