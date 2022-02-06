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

# Debian disk images
resource "libvirt_volume" "debian-base" {
  name = "debian-base"
  #source = "https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-genericcloud-amd64.qcow2"
  source = "/var/lib/libvirt/images/debian-11-genericcloud-amd64.qcow2"
  format = "qcow2"
}

resource "libvirt_volume" "debian" {
  count          = var.debian_cluster_size
  name           = "debian-${count.index}"
  base_volume_id = libvirt_volume.debian-base.id
}

# Debian cloud-init provisioning
data "template_file" "debian-provision" {
  count    = var.debian_cluster_size
  template = file("${path.module}/cloud_init_debian.cfg")
  vars = {
    user     = var.user
    password = var.password
    ssh_key  = var.ssh_key
    hostname = "debian-${count.index}"
    fqdn     = "debian-${count.index}.${var.domain_name}"
  }
}

data "template_file" "debian_network_config" {
  template = file("${path.module}/network_config_debian.cfg")
}

resource "libvirt_cloudinit_disk" "debian-init" {
  count          = var.debian_cluster_size
  name           = "debian-init-${count.index}.iso"
  user_data      = data.template_file.debian-provision[count.index].rendered
  network_config = data.template_file.debian_network_config.rendered
}

# Debian VMs
resource "libvirt_domain" "debian" {
  count   = var.debian_cluster_size
  name    = "debian-${count.index}"
  arch    = "x86_64"
  machine = "pc-i440fx-6.2"
  cpu { mode = "host-model" }
  vcpu   = var.debian_vm["cores"]
  memory = var.debian_vm["memory"]

  cloudinit = element(libvirt_cloudinit_disk.debian-init.*.id, count.index)

  network_interface {
    network_name   = "network"
    wait_for_lease = true
  }

  disk {
    volume_id = element(libvirt_volume.debian.*.id, count.index)
  }
}

# Ubuntu disk images
resource "libvirt_volume" "ubuntu-base" {
  name = "ubuntu-base"
  #source = "https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64-disk-kvm.img"
  source = "/var/lib/libvirt/images/focal-server-cloudimg-amd64-disk-kvm.img"
}

resource "libvirt_volume" "ubuntu" {
  count          = var.ubuntu_cluster_size
  name           = "ubuntu-${count.index}"
  base_volume_id = libvirt_volume.ubuntu-base.id
}

# Ubuntu cloud-init provisioning 
data "template_file" "ubuntu-provision" {
  count    = var.ubuntu_cluster_size
  template = file("${path.module}/cloud_init_debian.cfg")
  vars = {
    user     = var.user
    password = var.password
    ssh_key  = var.ssh_key
    hostname = "ubuntu-${count.index}"
    fqdn     = "ubuntu-${count.index}.${var.domain_name}"
  }
}

data "template_file" "ubuntu_network_config" {
  template = file("${path.module}/network_config_debian.cfg")
}

resource "libvirt_cloudinit_disk" "ubuntu-init" {
  count          = var.ubuntu_cluster_size
  name           = "ubuntu-init-${count.index}.iso"
  user_data      = data.template_file.ubuntu-provision[count.index].rendered
  network_config = data.template_file.ubuntu_network_config.rendered
}

# Ubuntu VMs
resource "libvirt_domain" "ubuntu" {
  count   = var.ubuntu_cluster_size
  name    = "ubuntu-${count.index}"
  arch    = "x86_64"
  machine = "pc-i440fx-6.2"
  cpu { mode = "host-model" }
  vcpu   = var.ubuntu_vm["cores"]
  memory = var.ubuntu_vm["memory"]

  cloudinit = element(libvirt_cloudinit_disk.ubuntu-init.*.id, count.index)

  network_interface {
    network_name   = "network"
    wait_for_lease = true
  }

  disk {
    volume_id = element(libvirt_volume.ubuntu.*.id, count.index)
  }
}