# ===================================================================
# Terraform และ Provider Configuration
#
# กำหนดเวอร์ชันของ Terraform และ vSphere Provider ที่ต้องการ
# ===================================================================
terraform {
  required_version = ">= 1.0" # แนะนำให้ใช้ Terraform เวอร์ชัน 1.0 ขึ้นไป

  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "~> 2.0" # ล็อกเวอร์ชัน Provider เพื่อความเสถียร
    }
  }
}

# ===================================================================
# Provider Configuration
#
# ตั้งค่าการเชื่อมต่อกับ vCenter Server
# ===================================================================
provider "vsphere" {
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vsphere_server

  # อนุญาตให้ใช้ SSL certificate ที่ไม่ได้ตรวจสอบ (สำหรับ Lab/Dev เท่านั้น)
  # ในสภาพแวดล้อม Production ควรตั้งค่าเป็น false และจัดการ Certificate ให้ถูกต้อง
  allow_unverified_ssl = true
}

# ===================================================================
# Data Sources
#
# ดึงข้อมูลของ Objects ที่มีอยู่แล้วใน vCenter เพื่อใช้อ้างอิง
# เป็น Best Practice ที่ดีกว่าการใช้ Hard-coded ID
# ===================================================================

# 1. ค้นหา Datacenter
data "vsphere_datacenter" "dc" {
  name = var.vsphere_datacenter
}

# 2. ค้นหา Datastore
data "vsphere_datastore" "datastore" {
  name          = var.vsphere_datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

# 3. ค้นหา ESXi Host ที่จะใช้
data "vsphere_host" "host" {
  name          = var.vsphere_host
  datacenter_id = data.vsphere_datacenter.dc.id
}

# 4. ค้นหา Network/Port Group
data "vsphere_network" "network" {
  name          = var.vsphere_network
  datacenter_id = data.vsphere_datacenter.dc.id
}

# 5. ค้นหา VM Template
data "vsphere_virtual_machine" "template" {
  name          = var.vsphere_template
  datacenter_id = data.vsphere_datacenter.dc.id
}

# 6. ค้นหา Folder ปลายทางที่จะเก็บ VM
data "vsphere_folder" "vm_folder" {
  path = var.vm_folder_path
}


# ===================================================================
# Resource: Virtual Machine
#
# ส่วนหลักในการสร้าง VM โดยการ Clone จาก Template
# ===================================================================
resource "vsphere_virtual_machine" "vm" {
  # --- การตั้งค่าพื้นฐาน ---
  name             = var.vm_name
  resource_pool_id = data.vsphere_host.host.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = data.vsphere_folder.vm_folder.path

  # --- การตั้งค่า Hardware ---
  num_cpus = var.vm_cpus
  memory   = var.vm_memory
  guest_id = data.vsphere_virtual_machine.template.guest_id
  firmware = data.vsphere_virtual_machine.template.firmware

  # --- การตั้งค่า Network Interface ---
  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  # --- การตั้งค่า Disk (สำคัญมาก) ---
  # เราต้องประกาศบล็อก disk เพื่อให้เป็นไปตาม Schema ของ Provider
  # แต่เราจะดึงค่าทั้งหมดมาจาก disk ใบแรกของ Template เพื่อให้เป็นการ Clone ที่สมบูรณ์
  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.template.disks[0].size
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks[0].eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.template.disks[0].thin_provisioned
  }

  # --- การ Clone และ Customization ---
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      # การปรับแต่งสำหรับ Linux Guest OS (จำเป็นต้องมี VMware Tools)
      linux_options {
        host_name = var.vm_name
        domain    = var.vm_domain
      }

      # การตั้งค่า Static IP Address สำหรับ Network Interface แรก
      network_interface {
        ipv4_address = var.vm_ipv4_address
        ipv4_netmask = var.vm_ipv4_netmask
      }

      # การตั้งค่า Gateway และ DNS
      ipv4_gateway    = var.vm_ipv4_gateway
      dns_server_list = var.vm_dns_servers
    }
  }

  # --- การตั้งค่าเพิ่มเติม ---
  # เปิดเครื่อง VM โดยอัตโนมัติหลังจากสร้างเสร็จ
  # ไม่ต้องรอ Guest IP/Network เพราะอาจใช้เวลานานและทำให้ timeout (ตั้งเป็น 0/5 เพื่อให้ Terraform ทำงานต่อได้เร็วขึ้น)
  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout  = 5
}