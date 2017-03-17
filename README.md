# Packer - CentOS 7 Deeplearning4J build box for Docker, AWS, Azure, Vagrant using Ansible provisioner

**Current CentOS Version Used**: 7.3

This example build configuration installs and configures CentOS 7 x86_64 with
the necessary elements for a deeplearning4j build box using Ansible, and then generates two Vagrant box files, for:

  - VirtualBox
  - VMware

It also creates images for :

  - Docker
  - Azure-ARM
  - Amazon-AWS

For the cloud providers, you will need to provision environment variables for
the cloud access credentials, see `centos7.json` at the root of the repo.

## Requirements

The following software must be installed/present on your local machine before you can use Packer to build the Vagrant box file:

  - [Packer](http://www.packer.io/)
  - [Vagrant](http://vagrantup.com/)
  - [VirtualBox](https://www.virtualbox.org/) (if you want to build the VirtualBox box)
  - [VMware Fusion](http://www.vmware.com/products/fusion/) (or Workstation - if you want to build the VMware box)
  - [Ansible](http://docs.ansible.com/intro_installation.html)

## Usage

Make sure all the required software (listed above) is installed, then cd to the directory containing this README.md file, and run:

    $ packer build centos7.json

After a few minutes, Packer should tell you the box was generated successfully.

If you want to only build a box for one of the supported virtualization platforms (e.g. only build the VMware box), add `--only=vmware-iso` to the `packer build` command:

    $ packer build --only=vmware-iso centos7.json

    $ packer build --only=virtualbox-iso centos7.json

    $ packer build --only=azure-arm centos7.json

    $ packer build --only=amazon-ebs centos7.json

    $ packer build --only=docker centos7.json


## License

Derived from https://github.com/geerlingguy/packer-centos-7, MIT license.

## Author Information

Created in 2014 by [Jeff Geerling](http://jeffgeerling.com/), author of [Ansible for DevOps](http://ansiblefordevops.com/).
