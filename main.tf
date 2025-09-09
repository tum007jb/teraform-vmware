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

  # หมายเหตุ: ใช้ในสภาพแวดล้อมทดสอบเท่านั้น สำหรับ Production ควรใช้ CA ที่เชื่อถือได้
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


# ===================================================================
# Resource: สร้าง Virtual Machine จาก Template
# ===================================================================
resource "vsphere_virtual_machine" "vm" {
  name             = var.vm_name
  resource_pool_id = data.vsphere_host.host.resource_pool_id # ใช้ Resource Pool ของ ESXi host ที่ระบุ
  datastore_id     = data.vsphere_datastore.datastore.id

  # กำหนดค่า Hardware
  num_cpus = var.vm_cpus
  memory   = var.vm_memory
  guest_id = data.vsphere_virtual_machine.template.guest_id # ใช้ Guest ID จาก Template

  # กำหนดค่า Network
  network_interface {
    network_id = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  # กำหนดค่า Disk จาก Template
  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.template.disks[0].size
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks[0].eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.template.disks[0].thin_provisioned
  }

  # ส่วนสำคัญ: การ Clone และปรับแต่ง (Customize)
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      # การปรับแต่งสำหรับ Linux (จำเป็นต้องมี VMware Tools)
      linux_options {
        host_name = var.vm_name
        domain    = var.vm_domain
      }

      # การตั้งค่า IP Address แบบ Static
      network_interface {
        ipv4_address = var.vm_ipv4_address
        ipv4_netmask = var.vm_ipv4_netmask
      }

      # ตั้งค่า Default Gateway และ DNS
      ipv4_gateway = var.vm_ipv4_gateway
      dns_server_list = var.vm_dns_servers
    }
  }

  # เปิดเครื่อง VM หลังสร้างเสร็จ
  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout  = 5
}