Role Name
=========

Prepping a system for ansible.  This should primarily be done to templates and is not intended to be part of the site file.

Requirements
------------
Ubuntu system with a user that is enable for ssh

Role Variables
--------------

host_ansible_username: Username to be created for ansible user
host_ansible_password: Password (encrypted) for new ansible user
host_ansible_authorized_key: Pub authorized key (text)

Dependencies
------------

None

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: ubuntu
      become: true
      gather_facts: False
      roles:
        - ubuntu_system_prep

License
-------

BSD

Author Information
------------------

Brandon Neill www.travellingtechie.com
