module "gitlab_vm" {
  source = "git::git@gitlab.int.jrtashjian.com:homelab/tfmod-proxmox-vm.git"

  node_name = "pve-node02"
  vm_name   = "gitlab-trixie"

  size = "xlarge"

  ansible_user       = var.ansible_user
  ansible_pass       = var.ansible_pass
  ansible_public_key = var.ansible_public_key

  tags = ["gitlab"]
}

module "gitlab_runners_standard" {
  source = "git::git@gitlab.int.jrtashjian.com:homelab/tfmod-proxmox-vm.git"

  count = 2

  node_name = count.index % 2 == 0 ? "pve-node02" : "pve-node03"
  vm_name   = format("gitlab-runner%02d", count.index + 1)

  size = "medium"

  ansible_user       = var.ansible_user
  ansible_pass       = var.ansible_pass
  ansible_public_key = var.ansible_public_key

  tags = ["gitlab", "gitlab-runner"]
}

module "gitlab_runners_large" {
  source = "git::git@gitlab.int.jrtashjian.com:homelab/tfmod-proxmox-vm.git"

  count = 2

  node_name = count.index % 2 == 0 ? "pve-node02" : "pve-node03"
  vm_name   = format("gitlab-runner%02d-large", count.index + 1)

  size = "compute-xlarge"

  root_datastore_id = "machines-fast"

  ansible_user       = var.ansible_user
  ansible_pass       = var.ansible_pass
  ansible_public_key = var.ansible_public_key

  tags = ["gitlab", "gitlab-runner"]
}
