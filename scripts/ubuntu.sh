#!/bin/bash -eux

apt-get update

apt-get install ansible python-software-properties software-properties-common -qq -y

add-apt-repository ppa:ansible/ansible -y

apt-get update

apt-get install ansible -qq -y
