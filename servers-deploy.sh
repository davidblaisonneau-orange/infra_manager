#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

XCI_RUN_ROOT=$(dirname $(readlink -f ${0}))
source ${XCI_RUN_ROOT}/scripts/xci-defaults.sh
source ${XCI_RUN_ROOT}/scripts/xci-rc.sh

# register our handler
trap submit_bug_report ERR

#-------------------------------------------------------------------------------
# This script should not be run as root
#-------------------------------------------------------------------------------
no_root_needed

#-------------------------------------------------------------------------------
# Install deps
#-------------------------------------------------------------------------------
step_banner "Install ansible (${XCI_ANSIBLE_PIP_VERSION})"
rm -rf ${HOME}/.local/lib/python2.7/
source ${XCI_RUN_ROOT}/scripts/install-ansible.sh
step_banner "Install deps for ansible plugins"
sudo pip install netaddr
yes|sudo pip uninstall pyopenssl||true

#-------------------------------------------------------------------------------
# Local Preparation
#-------------------------------------------------------------------------------
step_banner "Prepare local"
create_local_ssh_key

#-------------------------------------------------------------------------------
# Prepare jumphost
#  - configure local ansible
#  - set local project folders
#-------------------------------------------------------------------------------
step_banner "Prepare jumphost"
ansible-playbook ${XCI_ANSIBLE_VERBOSE} \
  -i ${XCI_RUN_ROOT}/jumphost_inventory.yml \
  ${XCI_RUN_ROOT}/opnfv-prepare-jumphost.yml

#-------------------------------------------------------------------------------
# Prepare servers
#  - set local VMs according to pdf/idf/xci_hosts files
#-------------------------------------------------------------------------------
step_banner "Prepare servers"
# We use sudo as required by ansible 2.3, not required in 2.4
ansible-galaxy install jriguera.configdrive
ansible-playbook ${XCI_ANSIBLE_VERBOSE} \
  -i ${XCI_RUN_ROOT}/jumphost_inventory.yml \
  ${XCI_RUN_ROOT}/opnfv-prepare-servers.yml

#-------------------------------------------------------------------------------
# Prepare and install Bifrost (using official doc way)
#  - prepare Bifrost source and config
#  - run env-setup
#  - run official install.yml
#  - run official enroll.yml
#  - run official deploy.yml
#-------------------------------------------------------------------------------
step_banner "Prepare and run Bifrost"
ansible-playbook ${XCI_ANSIBLE_VERBOSE} \
  -i ${XCI_PATH}/${POD_NAME}/etc/opnfv_hosts_inventory.yml \
  ${XCI_RUN_ROOT}/opnfv-deploy-os.yml

#-------------------------------------------------------------------------------
# Wait for servers
#-------------------------------------------------------------------------------
step_banner "Wait for servers to be deployed"
ansible all -m wait_for_connection \
  -i ${XCI_PATH}/${POD_NAME}/etc/ansible_inventory.yml

#-------------------------------------------------------------------------------
# Job done
#-------------------------------------------------------------------------------
step_banner "Servers deployed"
