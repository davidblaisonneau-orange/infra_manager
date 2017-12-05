OPNFV Infra manager
===================

This set of playbooks intend to prepare infrastructure to receive OPNFV
deployment. Its config source is share config files among all OPNFV installer:
 - PDF - Pod Description File: describing the hardware level of the
   infrastructure hosting the VIM
 - IDF - Installer Description File: A flexible file allowing installer to
   set specific parameters close to the infra settings, linked with the install
   sequence
This installer also used a xci_hosts definition, based on PDF, describing local
VMs required bu the XCI installer.

goals
-----

The goals of this installer are:
  - set all the servers (Virtual or Baremetal) ready to be used by an Installer.
  - install an OS is installed on each server
  - configure a managment IP, reachable using SSH
  - set an inventory of prepared nodes, including nodes roles, and nodes IP and
    interfaces (using the ansible inventory model)

Run
---

just Run
```
./servers-deploy.sh
```

Philosophy
----------

Those role, Bifrost in particular, are set to run 'as in official doc', it
implies that it may not be the cleaner way, but the one shared by externam
projects.

Variables
---------

* XCI_FLAVOR: the model of deployment:
 * aio: All in One: all in the same VM
 * mini: 1 installer node (aka opnfv_host), 1 controller, 1 compute
 * noha: 1 installer node (aka opnfv_host), 1 controller, 2 compute
 * ha: 1 installer node (aka opnfv_host), 3 controller, 2 compute
* OS_FAMILY: the OS type to install - No yet fully supported

Other variables are issued from PDF/IDF/xci_hosts
