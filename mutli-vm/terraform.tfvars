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
vm_folder_path     = "Tum-VM"

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
    name       = "DSO-RHEL9-RKE-MSWL01"
    hostname   = "master1wl"
    ip_address = "192.168.172.75"
  },
  "rke-node-02" = {
    name       = "DSO-RHEL9-RKE-MSWL02"
    hostname   = "master2wl"
    ip_address = "192.168.172.76"
  },
  "rke-node-03" = {
    name       = "DSO-RHEL9-RKE-MSWL03"
    hostname   = "master3wl"
    ip_address = "192.168.172.77"
  },
  "rke-node-04" = {
    name       = "DSO-RHEL9-RKE-WKWL01"
    hostname   = "worker1wl"
    ip_address = "192.168.172.78"
  },
  "rke-node-05" = {
    name       = "DSO-RHEL9-RKE-WKWL01"
    hostname   = "worker2wl"
    ip_address = "192.168.172.5579"
  }
}