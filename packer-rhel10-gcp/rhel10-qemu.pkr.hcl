packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = ">= 1.1.0"
    }
  }
}

source "qemu" "rhel10" {
  accelerator      = "kvm"
  vm_name          = "rhel10"
  output_directory = "rhel10"

  iso_url          = var.rhel10_iso
  iso_checksum     = var.rhel10_checksum

  disk_size        = "20G"
  format           = "qcow2"
  headless         = true

  memory           = 4096
  cpus             = 2

  http_directory   = "http"

  boot_wait = "10s"
  boot_command = [
    "<esc><wait>",
    "linux inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks-rhel10.cfg ",
    "inst.text inst.sshd<enter>"
  ]

  ssh_username     = "packer"
  ssh_password     = "packer"
  ssh_timeout      = "40m"

  shutdown_command = "sudo shutdown -P now"
}

build {
  sources = ["source.qemu.rhel10"]

  provisioner "ansible" {
    playbook_file = "ansible/playbook.yml"
  }

  provisioner "shell" {
    inline = [
      "sudo truncate -s 0 /etc/machine-id",
      "sudo cloud-init clean --logs",
      "sudo rm -rf /tmp/*"
    ]
  }
}
