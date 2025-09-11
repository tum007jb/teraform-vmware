# ====================================================
# ข้อมูล vCenter และ vSphere Objects (เหมือนเดิม)
# ====================================================
vsphere_user     = "surayossri@vsphere.local"
vsphere_password = "Addminit@ti0n"
vsphere_server   = "192.168.172.10"

vsphere_datacenter = "Datacenter"
vsphere_host       = "192.168.117.141"
vsphere_datastore  = "SESX1-DATA1"
vsphere_network    = "VLAN172"
vsphere_template   = "DSO-RHEL9-RKE-template"
vm_folder_path     = "DSO/vm/Tum-VM/RKE"

# ====================================================
# ข้อมูล Network ที่ใช้ร่วมกัน
# ====================================================
vm_ipv4_gateway  = "192.168.172.1"
vm_dns_servers   = ["192.168.170.11"]

# ====================================================
# <<<<<<<<<<< กำหนดค่าสำหรับ VM ทั้ง 5 เครื่องที่นี่ <<<<<<<<<<<
# ====================================================
vms = {
  "rke-node-01" = {
    name       = "rke-prod-node-01"
    hostname   = "rke-node-01"
    ip_address = "192.168.172.51"
  },
  "rke-node-02" = {
    name       = "rke-prod-node-02"
    hostname   = "rke-node-02"
    ip_address = "192.168.172.52"
  },
  "rke-node-03" = {
    name       = "rke-prod-node-03"
    hostname   = "rke-node-03"
    ip_address = "192.168.172.53"
  },
  "rke-node-04" = {
    name       = "rke-prod-node-04"
    hostname   = "rke-node-04"
    ip_address = "192.168.172.54"
  },
  "rke-node-05" = {
    name       = "rke-prod-node-05"
    hostname   = "rke-node-05"
    ip_address = "192.168.172.55"
  }
}