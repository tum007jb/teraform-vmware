# กรอกข้อมูลสำหรับเชื่อมต่อ vCenter ของคุณ
vsphere_user     = "surayossri@vsphere.local" # <--- แก้ไขเป็น User ของคุณ
vsphere_password = "Addminit@ti0n"          # <--- แก้ไขเป็น Password ของคุณ
vsphere_server   = "192.168.170.10"

# กรอกข้อมูล vSphere Objects ตามโจทย์
vsphere_datacenter = "DSO"             # <--- แก้ไขเป็นชื่อ Datacenter ของคุณ
vsphere_host       = "192.168.117.141"
vsphere_datastore  = "SESX1-DATA1"
vsphere_network    = "VLAN 172"                 # <--- แก้ไขเป็นชื่อ Port Group ที่ถูกต้อง
vsphere_template   = "DSO-RHEL9-RKE-template"

# กรอกข้อมูลสำหรับ VM ใหม่
vm_name          = "rhel9-web-01"
vm_ipv4_address  = "192.168.172.50"           # <--- กำหนด IP ที่ต้องการ
vm_ipv4_gateway  = "192.168.172.1"            # <--- แก้ไขเป็น Gateway ที่ถูกต้อง
vm_dns_servers   = ["192.168.1.1", "8.8.8.8"] # <--- แก้ไขเป็น DNS Server ของคุณ