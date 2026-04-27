# Docker Ansible Role

This Ansible role installs Docker CE on Debian-based systems from the official Docker APT repository. It conditionally sets up the repository and dependencies only on initial installation (via `stat` checks), installs latest package versions, enables the Docker service, and grants the `ansible_user` Docker group privileges. This enables DinD support for the GitLab Runner role.

## Role Variables

The role has no variables defined in `defaults/main.yml`. It depends on these Ansible facts:

```yaml
ansible_distribution_release:  # e.g. bookworm for repository suite
ansible_user:                  # user added to the `docker` group
```

Repository setup (`/etc/apt/sources.list.d/docker.sources` and keyring) is skipped on subsequent runs if already present. Package installation always updates to latest.
