terraform {
  required_version = ">= 1.1.5"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = ">= 0.6.14"
    }
  }
}

provider "libvirt" {
  uri = var.qemu_uri
}

locals {
  ips = [for i in range(var.cluster_size) : cidrhost(var.net_config["subnets"][0], var.net_config["start_addr"] + i)]
}

# Network
resource "libvirt_network" "debian_network" {
  name      = var.net_config["name"]
  mode      = var.net_config["mode"]
  domain    = var.net_config["domain"]
  addresses = var.net_config["subnets"]
  dns { enabled = true }
}

# Disk images
resource "libvirt_volume" "debian_base" {
  name   = "debian_base"
  source = var.debian_cloud_image["source"]
  format = var.debian_cloud_image["type"]
}

resource "libvirt_volume" "debian_disk" {
  count          = var.cluster_size
  name           = "debian_disk_${count.index}"
  size           = var.debian_vm["disk_size"]
  base_volume_id = libvirt_volume.debian_base.id
}

# cloud-init provisioning
data "template_file" "debian_provision" {
  count    = var.cluster_size
  template = file("${path.module}/templates/cloud_init/cloud_init_debian.cfg")
  vars = {
    hostname    = "debian-${count.index}"
    fqdn        = "debian-${count.index}.${var.net_config["domain"]}"
    user        = var.user
    password    = var.password
    ssh_keys    = jsonencode(var.ssh_keys)
    os_packages = jsonencode(var.os_packages)
  }
}

data "template_file" "debian_network_config" {
  count    = var.cluster_size
  template = file("${path.module}/templates/cloud_init/network_config_debian.cfg")
  vars = {
    ip             = "${local.ips["${count.index}"]}/${var.net_config["cidr"]}"
    gateway        = var.net_config["gateway"]
    search_domains = jsonencode(var.net_config["search_domains"])
    dns_servers    = jsonencode(var.net_config["dns_servers"])
  }
}

resource "libvirt_cloudinit_disk" "debian_init" {
  count          = var.cluster_size
  name           = "debian-init-${count.index}.iso"
  user_data      = data.template_file.debian_provision[count.index].rendered
  network_config = data.template_file.debian_network_config[count.index].rendered
}

# VMs
resource "libvirt_domain" "debian_vm" {
  count   = var.cluster_size
  name    = "debian-${count.index}"
  running = true

  vcpu   = var.debian_vm["cores"]
  memory = var.debian_vm["memory"]
  cpu { mode = "host-model" }

  cloudinit = element(libvirt_cloudinit_disk.debian_init.*.id, count.index)

  disk { volume_id = element(libvirt_volume.debian_disk.*.id, count.index) }

  network_interface {
    network_name = var.net_config["name"]
    addresses    = [local.ips["${count.index}"]]
    hostname     = "debian-${count.index}"
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
}

# Generate ansible inventory
resource "local_file" "hosts" {
  content         = templatefile("${path.module}/templates/ansible/inventory.tftpl", { hosts = local.ips })
  file_permission = "0644"
  filename        = "ansible/inventory/hosts"
}

# List VMs and their IPs
output "debian_ip_addresses" {
  value = {
    for vm in libvirt_domain.debian_vm :
    vm.name => vm.network_interface[0].addresses[0]
  }
}
