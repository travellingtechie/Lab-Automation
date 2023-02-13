Role Name
=========

Installs the necessary packages, then installs and configures mariadb using Podman on an Ubuntu host

Requirements
------------

Any pre-requisites that may not be covered by Ansible itself or the role should be mentioned here. For instance, if the role uses the EC2 module, it may be a good idea to mention in this section that the boto package is required.

Role Variables
--------------

vars/main.yml
packages: includes packages necessary for install, currently just podman

password file: a plaintext file with the admin password, no other whitepace or characters.

Dependencies
------------

A list of other roles hosted on Galaxy should go here, plus any details in regards to parameters that may need to be set for other roles, or variables that are used from other roles.

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

- hosts: controlcenter
  become: true
  gather_facts: False
  vars:
  roles:
    - ubuntu_install_portainer

License
-------

BSD

Author Information
------------------

An optional section for the role authors to include contact information, or a website (HTML is not allowed).