# GitLab Infrastructure

This repository manages the provisioning and configuration of a self-hosted GitLab instance and its CI/CD runners using **Terraform** for VM provisioning and **Ansible** for host-level configuration.

**Terraform** provisions the GitLab VM and runner VMs on Proxmox using a shared VM module. It creates a GitLab server, standard-sized runners, and large runners spread across cluster nodes.

**Ansible** configures the runner VMs with Docker and the GitLab Runner service, deploys a shared S3-compatible (MinIO) cache configuration, and manages runner registration and deregistration against the GitLab instance.

## Terraform

### Local Development

To run Terraform commands locally, use the provided `.env.example` as a template:

```bash
cp .env.example .env
```

Fill in the values in `.env` using [1Password Secret References](https://developer.1password.com/docs/cli/secret-references/) (e.g. `op://vault/item/field`) or plain values. Then use the [1Password CLI](https://developer.1password.com/docs/cli) to inject secrets at runtime:

```bash
# Preview changes
op run --env-file=".env" -- terraform plan

# Apply changes
op run --env-file=".env" -- terraform apply
```

### Variables for CI/CD Pipeline

The pipeline utilizes [1Password Service Account](https://developer.1password.com/docs/service-accounts) for retrieving passwords [defined as variables](https://docs.gitlab.com/ee/ci/variables/#define-a-cicd-variable-in-the-ui) using the [Secret Reference](https://developer.1password.com/docs/cli/secret-references/) syntax.

#### GitLab CI/CD Workflow Variables

Required by the GitLab CI/CD workflow itself. Set these as CI/CD variables in the GitLab project settings.

| Variable | Description |
|---|---|
| `OP_SERVICE_ACCOUNT_TOKEN` | The service account token used by the GitLab CI/CD workflow to authenticate with 1Password. |

#### Environment Variables

Credentials passed to Terraform at runtime via 1Password secret references. Set these as CI/CD variables in the GitLab project settings.

| Variable | Description |
|---|---|
| `PROXMOX_VE_ENDPOINT` | The URL of the Proxmox Virtual Environment API endpoint. |
| `PROXMOX_VE_USERNAME` | The username and realm for the Proxmox Virtual Environment API. |
| `PROXMOX_VE_PASSWORD` | The password for the Proxmox Virtual Environment API. |
| `TF_VAR_ansible_user` | The user Ansible connects as on provisioned VMs. |
| `TF_VAR_ansible_pass` | The password for the Ansible user. |
| `TF_VAR_ansible_public_key` | The SSH public key added to provisioned VMs. |

## Ansible

Ansible configures the GitLab runner VMs. Playbooks and roles are in the `ansible/` directory.

### Setup

Install the required Ansible collections:

```bash
cd ansible
ansible-galaxy install --force -r requirements.yml
```

Run the vault setup script to fetch the Ansible vault password and encrypt vault files using [1Password CLI](https://developer.1password.com/docs/cli):

```bash
./setup-vaults.sh
```

### Playbooks

**Deploy** — installs Docker and GitLab Runner, and deploys the runner config template:

```bash
ansible-playbook playbooks/deploy.yml
```

**Register runners** — creates a runner via the GitLab API and registers it on each host (skips hosts already registered):

```bash
ansible-playbook playbooks/register-runners.yml
```

**Unregister runners** — deregisters and removes the runner config from each host:

```bash
ansible-playbook playbooks/unregister-runners.yml
```

**Docker prune** — runs `docker system prune --all --force` on all runner hosts:

```bash
ansible-playbook playbooks/docker-prune.yml
```
