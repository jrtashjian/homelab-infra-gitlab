# GitLab Ansible Role

This Ansible role installs GitLab CE on Debian-based systems from the official GitLab APT repository via the `script.deb.sh` installer. It uses `stat` checks (on `/usr/bin/gitlab-ctl` and repo list) to perform initial setup only once, copies cluster SSL certificates to `/etc/gitlab/ssl/`, templates `/etc/gitlab/gitlab.rb` from `gitlab.rb.j2`, and triggers `gitlab-ctl reconfigure` via handler on changes. Configuration integrates MinIO object storage (artifacts, LFS, uploads, registry, etc. using `gitlab-artifacts` and similar buckets), SMTP email, OpenID Connect Omniauth (from vault), and SSL.

## Role Variables

Variables with defaults are defined in `defaults/main.yml`:

```yaml
gitlab_domain: "gitlab.example.com"
gitlab_external_url: "https://{{ gitlab_domain }}/"
gitlab_omniauth_providers: ""
gitlab_object_store_connection: ""
gitlab_ldap_servers: ""
gitlab_smtp: {}
gitlab_registry_storage: ""
gitlab_upgrade_version: ""
```

Required definitions in `group_vars/all/vars.yml` and `group_vars/gitlab/vars.yml` (plus vault secrets):

```yaml
cluster_ssl_certificate: "{{ inventory_dir }}/files/int.jrtashjian.com.crt"
cluster_ssl_certificate_key: "{{ inventory_dir }}/files/int.jrtashjian.com.key"
gitlab_smtp: {address: "...", ...}
gitlab_object_store_connection: |-
  { ... MinIO endpoint, keys ... }
gitlab_omniauth_providers: |-
  [{name: 'openid_connect', ...}]
```

The template configures external_url, nginx['ssl_certificate'], object_store buckets, SMTP, Omniauth providers, registry, and more. `gitlab-ctl reconfigure` is the handler.
