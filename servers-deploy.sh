#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

source scripts/bash-defaults.sh

submit_bug_report() {
  echo ""
  echo "---------------------------------------------------------------------"
  echo "Oh nooooo! The XCI servers deployment failed miserably :-("
  echo ""
  echo "If you need help, please choose one of the following options"
  echo "* #opnfv-pharos @ freenode network"
  echo "* opnfv-tech-discuss mailing list:"
  echo "  https://lists.opnfv.org/mailman/listinfo/opnfv-tech-discuss"
  echo "  Please prefix the subject with [XCI]"
  echo "* https://jira.opnfv.org (Release Engineering project)"
  echo ""
  echo "Do not forget to submit the following information on your bug report:"
  echo ""
  git diff --quiet && echo "releng-xci tree status: clean" \
    || echo "releng-xci tree status: local modifications"
  echo "Environment variables:"
  env | grep --color=never '\(OPNFV\|XCI\|OPENSTACK\)'
  echo "---------------------------------------------------------------------"
}

step_banner() {
  echo ""
  echo "====================================================================="
  date
  echo "$1"
  echo "====================================================================="
  echo ""
}

# register our handler
trap submit_bug_report ERR

#-------------------------------------------------------------------------------
# This script should not be run as root
#-------------------------------------------------------------------------------
if [[ $(whoami) == "root" ]]; then
    echo "WARNING: This script should not be run as root!"
    echo "Elevated privileges are aquired automatically when necessary"
    echo "Waiting 10s to give you a chance to stop the script (Ctrl-C)"
    for x in $(seq 10 -1 1); do echo -n "$x..."; sleep 1; done
fi

#-------------------------------------------------------------------------------
# Install deps
#-------------------------------------------------------------------------------
step_banner "Install ansible (${XCI_ANSIBLE_PIP_VERSION})"
source scripts/install-ansible.sh
step_banner "Install deps for ansible plugins"
sudo pip install netaddr

#-------------------------------------------------------------------------------
# Create the ssh keys if need
#-------------------------------------------------------------------------------
if [ ! -e "$HOME/.ssh/id_rsa" ] ; then
  ssh-keygen -f  ~/.ssh/id_rsa -t rsa -N ''
fi

#-------------------------------------------------------------------------------
# Prepare jumphost
#  - configure local ansible
#  - set local project folders
#-------------------------------------------------------------------------------
step_banner "Prepare jumphost"
ansible-playbook ${XCI_ANSIBLE_VERBOSE} \
  -i jumphost_inventory.yml \
  opnfv-prepare-jumphost.yml

#-------------------------------------------------------------------------------
# Prepare servers
#  - set local VMs according to pdf/idf/xci_hosts files
#-------------------------------------------------------------------------------
step_banner "Prepare servers"
ansible-galaxy install jriguera.configdrive
ansible-playbook ${XCI_ANSIBLE_VERBOSE} \
  -i jumphost_inventory.yml \
  opnfv-prepare-servers.yml

#-------------------------------------------------------------------------------
# Prepare and install Bifrost (using official doc way)
#  - prepare Bifrost source and config
#  - run env-setup
#  - run official install.yml
#  - run official enroll.yml
#  - run official deploy.yml
#-------------------------------------------------------------------------------
step_banner "Prepare and run Bifrost"
export POD_NAME=$(grep 'pod_name:' var/idf.yml  | awk '{ print $2}')
sleep 10  # to avoid a strange ansible ssh connection error
ansible-playbook ${XCI_ANSIBLE_VERBOSE} \
  -i ${XCI_PATH}/${POD_NAME}/etc/opnfv_hosts_inventory.yml \
  opnfv-deploy-os.yml

#-------------------------------------------------------------------------------
# Job done
#-------------------------------------------------------------------------------
step_banner "Servers deployed"
