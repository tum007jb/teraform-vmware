# ... (ตัวแปร vCenter และ vSphere Objects เหมือนเดิม) ...
variable "vsphere_user" { #...
}
variable "vsphere_password" { #...
}
variable "vsphere_server" { #...
}
variable "vsphere_datacenter" { #...
}
variable "vsphere_host" { #...
}
variable "vsphere_datastore" { #...
}
variable "vsphere_network" { #...
}
variable "vsphere_template" { #...
}
variable "vm_folder_path" { #...
}

# -------------------------------------
# ตัวแปรสำหรับ VM ใหม่ (แบบ Map)
# -------------------------------------
# <<<<<<<<<<< ตัวแปรใหม่สำหรับกำหนด VM หลายเครื่อง <<<<<<<<<<<
variable "vms" {
  type = map(object({
    name       = string
    hostname   = string
    ip_address = string
  }))
  description = "A map of virtual machines to create, where each key is a logical name and the value contains the VM's specific configuration."
}

# -------------------------------------
# ตัวแปรสำหรับ Hardware และ Network ที่ใช้ร่วมกัน
# -------------------------------------
variable "vm_cpus" {
  type    = number
  default = 4
}

variable "vm_memory" {
  type    = number
  default = 16384
}

variable "vm_domain" {
  type    = string
  default = "local"
}

variable "vm_ipv4_netmask" {
  type    = number
  default = 24
}

variable "vm_ipv4_gateway" {
  type = string
}

variable "vm_dns_servers" {
  type    = list(string)
  default = ["8.8.8.8", "8.8.4.4"]
}