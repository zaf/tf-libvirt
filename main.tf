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

# Network
resource "libvirt_network" "debian_network" {
  name      = "debian_network"
  mode      = "nat"
  domain    = var.net_config["domain"]
  addresses = var.net_config["subnets"]
  dns {
    enabled = true
  }
}

# Disk images
resource "libvirt_volume" "debian_base" {
  name = "debian_base"
  #source = "https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-genericcloud-amd64.qcow2"
  source = "/var/lib/libvirt/images/debian-11-genericcloud-amd64.qcow2"
  format = "qcow2"
}

resource "libvirt_volume" "debian_disk" {
  count = var.cluster_size
  name  = "debian_disk_${count.index}"
  #size           = var.debian_vm["disk_size"]
  base_volume_id = libvirt_volume.debian_base.id
}

# cloud-init provisioning
data "template_file" "debian_provision" {
  count    = var.cluster_size
  template = file("${path.module}/cloud_init_debian.cfg")
  vars = {
    user     = var.user
    password = var.password
    ssh_key  = var.ssh_key
    hostname = "debian-${count.index}"
    fqdn     = "debian-${count.index}.${var.net_config["domain"]}"
  }
}

data "template_file" "debian_network_config" {
  count    = var.cluster_size
  template = file("${path.module}/network_config_debian.cfg")
  vars = {
    ip             = "${lookup(var.ips, count.index)}"
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
resource "libvirt_domain" "debian" {
  count   = var.cluster_size
  name    = "debian-${count.index}"
  arch    = "x86_64"
  machine = "pc-i440fx-6.2"
  cpu { mode = "host-model" }
  vcpu    = var.debian_vm["cores"]
  memory  = var.debian_vm["memory"]
  running = true

  cloudinit = element(libvirt_cloudinit_disk.debian_init.*.id, count.index)

  network_interface {
    network_name   = "debian_network"
    wait_for_lease = true
  }

  disk {
    volume_id = element(libvirt_volume.debian_disk.*.id, count.index)
  }
}
