# GitLab Runner Ansible Role

This Ansible role installs GitLab Runner on Debian-based systems from the official GitLab APT repository and provisions a TOML configuration template for the Docker executor. The template integrates S3 caching against a MinIO instance (using the `gitlab-runners-cache` bucket) and mounts the Docker socket for DinD support. Runner registration, service management, and Docker pruning are handled by separate playbooks (`register-runners.yml`, `unregister-runners.yml`, `docker-prune.yml`).

## Role Variables

Variables are defined in `defaults/main.yml` with defaults:

```yaml
gitlab_runner_registration_token: ''
gitlab_runner_run_untagged: true
gitlab_runner_tags: []
```

Required `gitlab_runners_cache_s3` in `group_vars/gitlab-runner/vars.yml`:

```yaml
gitlab_runners_cache_s3:
  server_address: "{{ minio_endpoint }}"
  access_key: "{{ minio_access_key_id }}"
  secret_key: "{{ minio_secret_access_key }}"
```

These are templated into `/home/{{ ansible_user }}/runner-config-template.toml`. Host facts (`ansible_processor_nproc`, `ansible_memtotal_mb`) set Docker resource limits.

Template configures Docker executor with S3 cache (`gitlab-runners-cache` bucket, `Insecure = true`), concurrent=1, and mounts for `/var/run/docker.sock` and `/cache`.
