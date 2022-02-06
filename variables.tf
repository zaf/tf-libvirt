# Configuration
variable "qemu_uri" {
  description = "Qemu connection URI"
  type        = string
  default     = "qemu:///system"
}

variable "domain_name" {
  description = "Local domain"
  type        = string
  default     = "home"
}

variable "debian_cluster_size" {
  description = "Number of Debian instances to provision."
  type        = number
  default     = 2
}

variable "ubuntu_cluster_size" {
  description = "Number of Ubuntu instances to provision."
  type        = number
  default     = 2
}

variable "debian_vm" {
  description = "Debian VM hardware specs"
  type        = map(number)
  default = {
    cores  = 4,
    memory = 4096,
    disk   = 5368709120
  }
}

variable "ubuntu_vm" {
  description = "Ubuntu VM hardware specs"
  type        = map(number)
  default = {
    cores  = 4,
    memory = 4096,
    disk   = 5368709120
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