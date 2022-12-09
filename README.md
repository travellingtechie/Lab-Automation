# Lab Automation
A collection of scripts that I use for Lab Builds

## Prerequisites
I currently run everything inside of a python venv (mostly in Pycharm)
THis is the configuration I use:
```commandline
pip install --upgrade pip
mkdir projects/ansible
apt install python3.8-venv
python3 -m venv venv --prompt="Ninja wk2"
pip install ansible pyvmomi
pip install --upgrade setuptools==62.0.0
pip install --upgrade git+https://github.com/vmware/vsphere-automation-sdk-python.git

```

I'm trying to use requirements files, however this is not yet working in all environments:

Install Python and Create Virtual Environment
```commandline
pip install --upgrade pip
mkdir projects/ansible
apt install python3.8-venv
python3 -m venv venv --prompt="ansible"
pip install -r requirements.txt
```

Install Ansible collections
```commandline
cd ansible/collections

```
