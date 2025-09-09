# ===================================================================
# Resource: สร้าง Virtual Machine จาก Template (ฉบับแก้ไข)
# ===================================================================
resource "vsphere_virtual_machine" "vm" {
  name             = var.vm_name
  resource_pool_id = data.vsphere_host.host.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id

  # กำหนดค่า Hardware
  num_cpus = var.vm_cpus
  memory   = var.vm_memory
  guest_id = data.vsphere_virtual_machine.template.guest_id

  # (Best Practice) กำหนด Firmware ให้ตรงกับ Template
  firmware = data.vsphere_virtual_machine.template.firmware
  
  # ถ้า Template เป็น EFI อาจต้องกำหนด Secure Boot ให้ตรงกันด้วย
  # efi_secure_boot_enabled = data.vsphere_virtual_machine.template.efi_secure_boot_enabled

  # กำหนดค่า Network
  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  # ----> ลบบล็อก disk {} ทั้งหมดออกจากส่วนนี้ <----
  # Terraform จะทำการ clone disk จาก template ให้โดยอัตโนมัติเมื่อใช้ clone {}

  # ส่วนสำคัญ: การ Clone และปรับแต่ง (Customize)
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