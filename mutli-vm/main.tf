# ===================================================================
# Terraform และ Provider Configuration
# ===================================================================
terraform {
  required_version = ">= 1.0"
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "~> 2.0"
    }
  }
}
# ===================================================================
# Provider Configuration
# ===================================================================
provider "vsphere" {
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vsphere_server
  allow_unverified_ssl = true
}
# ===================================================================
# Data Sources
# ===================================================================
data "vsphere_datacenter" "dc" { name = var.vsphere_datacenter }

data "vsphere_datastore" "datastore" {
  name          = var.vsphere_datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_host" "host" {
  name          = var.vsphere_host
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.vsphere_network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.vsphere_template
  datacenter_id = data.vsphere_datacenter.dc.id
}

# <<<<<<<<<<< เพิ่มบล็อกที่หายไปกลับเข้ามาแล้ว <<<<<<<<<<<
data "vsphere_folder" "vm_folder" {
  path = var.vm_folder_path
}

# ===================================================================
# Resource: สร้าง Virtual Machines หลายเครื่องด้วย for_each
# ===================================================================
resource "vsphere_virtual_machine" "vm" {
  for_each = var.vms
  
  name             = each.value.name
  resource_pool_id = data.vsphere_host.host.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = data.vsphere_folder.vm_folder.path # บรรทัดนี้จะหา data block เจอแล้ว
  
  num_cpus = var.vm_cpus
  memory   = var.vm_memory
  guest_id = data.vsphere_virtual_machine.template.guest_id
  firmware = data.vsphere_virtual_machine.template.firmware
  
  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.template.disks[0].size
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks[0].eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.template.disks[0].thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
    
    customize {
      linux_options {
        host_name = each.value.hostname
        domain    = var.vm_domain
      }
      
      network_interface {
        ipv4_address = each.value.ip_address
        ipv4_netmask = var.vm_ipv4_netmask
      }
      
      ipv4_gateway    = var.vm_ipv4_gateway
      dns_server_list = var.vm_dns_servers
    }
  }
  
  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout  = 5
}