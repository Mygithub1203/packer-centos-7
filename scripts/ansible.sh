#!/bin/bash -eux

# Install EPEL repository.
yum -y install epel-release python-pip yum-utils gcc openssl-devel

yum-builddep -y ansible

# Install Ansible.
# yum -y install ansible
pip install --upgrade pip
pip install --upgrade ansible
