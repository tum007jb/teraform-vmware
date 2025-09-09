# ===================================================================
# Terraform และ Provider Configuration
# ===================================================================
terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "~> 2.0"
    }
  }
}

provider "vsphere" {
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vsphere_server
  allow_unverified_ssl = true
}

# ===================================================================
# Data Sources: ดึงข้อมูล vSphere Objects ที่มีอยู่แล้ว
# ===================================================================
data "vsphere_datacenter" "dc" {
  name = var.vsphere_datacenter
}

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

# DATA SOURCE: ค้นหา Folder ที่จะใช้เก็บ VM
data "vsphere_folder" "vm_folder" {
  path = var.vm_folder_path
}

# ===================================================================
# Resource: สร้าง Virtual Machine จาก Template
# ===================================================================
resource "vsphere_virtual_machine" "vm" {
  name             = var.vm_name
  resource_pool_id = data.vsphere_host.host.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = data.vsphere_folder.vm_folder.path # <<<<<<<<<<< เพิ่มตรงนี้

  # กำหนดค่า Hardware
  num_cpus = var.vm_cpus
  memory   = var.vm_memory
  guest_id = data.vsphere_virtual_machine.template.guest_id
  firmware = data.vsphere_virtual_machine.template.firmware # <<<< แก้ไขจากครั้งก่อน

  # กำหนดค่า Network
  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  # ไม่ต้องมีบล็อก disk {} เพราะเราจะ clone จาก template

  # การ Clone และปรับแต่ง (Customize)
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = var.vm_name
        domain    = var.vm_domain
      }

      network_interface {
        ipv4_address = var.vm_ipv4_address
        ipv4_netmask = var.vm_ipv4_netmask
      }

      ipv4_gateway    = var.vm_ipv4_gateway
      dns_server_list = var.vm_dns_servers
    }
  }

  # เปิดเครื่อง VM หลังสร้างเสร็จ
  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout  = 5
}