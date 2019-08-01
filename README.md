JupyterHub (Lab) server deployment
==================================

This porject containes terraform file for deployment of JupyterHub server.

Prerequirements
_______________
* Ansible:
** linux-system-roles.network - role installed
* Terraform:
** remote backend configured
* Hetzner cloud:
** floating ip created
** "home" volume created
** ssh public key uploaded
* IPA domain created

Variables
_________
Some variables have default value (you can redefine them by exporting environment variables starting with `TF_VAR_`).
```
server_type = "cx31-ceph"
remote_user = "root"
server_image = "centos-7"
```

Environment variables
_____________________
You need to have a following environment variables:
* `HCLOUD_TOKEN`:
`export HCLOUD_TOKEN="KJKHUH453HH0HIU"`
* `TF_VAR_ssh_key_private`:
`export TF_VAR_ssh_key_private="~/.ssh/id_ed25519"`
* `TF_VAR_ssh_key`:
`export TF_VAR_ssh_key="123456"`
* `TF_VAR_domain`:
`export TF_VAR_domain="example.com"`
