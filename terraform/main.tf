provider "esxi" {
  esxi_hostname = var.esxi_hostname
  esxi_username = var.esxi_username
  esxi_password = var.esxi_password
}

locals {
  ovf_source      = "https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/39.20240407.3.0/x86_64/fedora-coreos-39.20240407.3.0-vmware.x86_64.ova"
  guest_num_vcpu  = 4
  guest_memory_gb = 8
  guest_disk_gb   = 30
}

data "ct_config" "ignition_master" {
  content      = templatefile("./ignition.yaml", { hostname = "k8s_test_master" })
  strict       = true
  pretty_print = false
}

resource "esxi_guest" "k8s_test_master" {
  ovf_source = local.ovf_source
  guestos    = "coreos64"

  virthwver = "21"

  boot_firmware = "efi"

  guest_name = "k8s_test_master"
  power      = "on"

  numvcpus       = local.guest_num_vcpu
  memsize        = max(local.guest_memory_gb * 1024, 512)
  disk_store     = "datastore1"
  boot_disk_size = max(local.guest_disk_gb, 20)

  network_interfaces {
    virtual_network = "vm-internal-network"
  }

  guestinfo = {
    "ignition.config.data.encoding"          = "gzip+base64"
    "ignition.config.data" = base64gzip(data.ct_config.ignition_master.rendered)
  }
}


data "ct_config" "ignition_worker" {
  content      = templatefile("./ignition.yaml", { hostname = "k8s_test_worker" })
  strict       = true
  pretty_print = false
}

resource "esxi_guest" "k8s_test_worker" {
  ovf_source = local.ovf_source
  guestos    = "coreos64"

  virthwver = "21"

  boot_firmware = "efi"

  guest_name = "k8s_test_worker"
  power      = "on"

  numvcpus       = local.guest_num_vcpu
  memsize        = max(local.guest_memory_gb * 1024, 512)
  disk_store     = "datastore1"
  boot_disk_size = max(local.guest_disk_gb, 20)

  network_interfaces {
    virtual_network = "vm-internal-network"
  }

  guestinfo = {
    "ignition.config.data.encoding"          = "gzip+base64"
    "ignition.config.data" = base64gzip(data.ct_config.ignition_master.rendered)
  }
}
