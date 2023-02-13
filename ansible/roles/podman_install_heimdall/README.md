Role Name
=========

This is the Template I use for creating new roles that install a particular container.  I put a reference to heimdall that can be replaced with the actual container.


Requirements
------------

Any pre-requisites that may not be covered by Ansible itself or the role should be mentioned here. For instance, if the role uses the EC2 module, it may be a good idea to mention in this section that the boto package is required.

Here are the changes that need to be made to use this template for a particular container:
- Update DeployContainer.yml with information from the command line to deploy the container
- Add any additional tasks to main.yml that are necessary before or after DeployContainer

Role Variables
--------------

vars/main.yml
podman_packages: includes packages necessary for install, currently just podman

password file: a plaintext file with the admin password, no other whitepace or characters.

Dependencies
------------

A list of other roles hosted on Galaxy should go here, plus any details in regards to parameters that may need to be set for other roles, or variables that are used from other roles.

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

- hosts: controlcenter
  become: true
  vars:
  roles:
    - podman_install_heimdall

License
-------

BSD

Author Information
------------------

Brandon Neill
brandon@travellingtechie.com
https://www.travellingtechie.com
