# ตัวแปรสำหรับ vCenter Connection
variable "vsphere_user" {
  type        = string
  description = "vCenter username."
  sensitive   = true
}

variable "vsphere_password" {
  type        = string
  description = "vCenter password."
  sensitive   = true
}

variable "vsphere_server" {
  type        = string
  description = "vCenter server FQDN or IP address."
}

# ตัวแปรสำหรับ vSphere Objects
variable "vsphere_datacenter" {
  type        = string
  description = "The name of the datacenter in vCenter."
}

variable "vsphere_host" {
  type        = string
  description = "The target ESXi host IP or FQDN."
}

variable "vsphere_datastore" {
  type        = string
  description = "The target datastore name."
}

variable "vsphere_network" {
  type        = string
  description = "The name of the network/port group."
}

# ตัวแปรสำหรับระบุ Folder ของ VM
variable "vm_folder_path" {
  type        = string
  description = "The full path of the folder to place the VM in (e.g., 'Folder/SubFolder')."
  default     = "DSO/vm/Tum-VM/RKE" # ตั้งค่า default ตามโจทย์
}

variable "vsphere_template" {
  type        = string
  description = "The name of the VM template to clone from."
}

# ตัวแปรสำหรับ VM ใหม่
variable "vm_name" {
  type        = string
  description = "The name for the new virtual machine."
  default     = "my-rhel9-vm"
}

variable "vm_cpus" {
  type        = number
  description = "Number of CPUs for the new VM."
  default     = 2
}

variable "vm_memory" {
  type        = number
  description = "Memory in MB for the new VM."
  default     = 4096
}

variable "vm_domain" {
  type        = string
  description = "The domain name for the new VM."
  default     = "local"
}

# ตัวแปรสำหรับ Network Customization
variable "vm_ipv4_address" {
  type        = string
  description = "The static IPv4 address for the new VM."
}

variable "vm_ipv4_netmask" {
  type        = number
  description = "The IPv4 subnet mask in bits (e.g., 24 for 255.255.255.0)."
  default     = 24
}

variable "vm_ipv4_gateway" {
  type        = string
  description = "The IPv4 default gateway."
}

variable "vm_dns_servers" {
  type        = list(string)
  description = "List of DNS servers."
  default     = ["8.8.8.8", "8.8.4.4"]
}