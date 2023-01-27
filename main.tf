terraform {
  required_version = ">= 1.3.5"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = ">= 0.7.1"
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
resource "libvirt_network" "vm_network" {
  name      = var.net_config["name"]
  mode      = var.net_config["mode"]
  domain    = var.net_config["domain"]
  addresses = var.net_config["subnets"]
  dns { enabled = true }
}

# Disk images
resource "libvirt_volume" "vm_base" {
  name   = "${var.vmname}_base"
  source = var.cloud_image["source"]
  format = var.cloud_image["type"]
}

resource "libvirt_volume" "vm_disk" {
  count          = var.cluster_size
  name           = "${var.vmname}_disk_${count.index}"
  size           = var.vm["disk_size"]
  base_volume_id = libvirt_volume.vm_base.id
}

# cloud-init provisioning
resource "libvirt_cloudinit_disk" "vm_init" {
  count = var.cluster_size
  name  = "${var.vmname}-init-${count.index}.iso"
  user_data = templatefile("${path.module}/templates/cloud_init/cloud_init.cfg",
    {
      hostname    = "${var.vmname}-${count.index}",
      fqdn        = "${var.vmname}-${count.index}.${var.net_config["domain"]}",
      users       = var.users,
      os_packages = jsonencode(var.os_packages)
    }
  )
  network_config = templatefile("${path.module}/templates/cloud_init/network_config.cfg",
    {
      ip             = "${local.ips["${count.index}"]}/${var.net_config["cidr"]}",
      gateway        = var.net_config["gateway"],
      search_domains = jsonencode(var.net_config["search_domains"]),
      dns_servers    = jsonencode(var.net_config["dns_servers"])
    }
  )
}

# VMs
resource "libvirt_domain" "vm" {
  count   = var.cluster_size
  name    = "${var.vmname}-${count.index}"
  running = true

  vcpu   = var.vm["cores"]
  memory = var.vm["memory"]
  cpu { mode = "host-model" }

  cloudinit = element("libvirt_cloudinit_disk.${var.vmname}_init.*.id, count.index")

  disk { volume_id = element("libvirt_volume.${var.vmname}_disk.*.id, count.index") }

  network_interface {
    network_name = var.net_config["name"]
    addresses    = [local.ips["${count.index}"]]
    hostname     = "${var.vmname}-${count.index}"
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
output "ip_addresses" {
  value = {
    for vm in libvirt_domain.vm :
    vm.name => vm.network_interface[0].addresses[0]
  }
}
