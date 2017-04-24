#!/bin/bash -eux

# Install EPEL repository.
yum -y install epel-release yum-utils gcc openssl-devel
yum -y update
yum -y install python-pip python-wheel
yum -y  upgrade python-setuptools
yum-builddep -y ansible

# Install Ansible.
# yum -y install ansible
pip install --upgrade pip
pip install --upgrade ansible
