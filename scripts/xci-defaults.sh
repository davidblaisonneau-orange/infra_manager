#!/bin/bash

export XCI_PATH=${XCI_PATH:-/opt/xci}

export XCI_ANSIBLE_PIP_VERSION=${XCI_ANSIBLE_PIP_VERSION:-2.4.2.0}
export XCI_ANSIBLE_VERBOSE=${XCI_ANSIBLE_VERBOSE:--vvv}

export POD_NAME=$(grep 'pod_name:' ${XCI_RUN_ROOT}/var/idf.yml|awk '{ print $2}')

##
# Ensure local bin folder is in the PATH
##
if [[ -z $(echo ${PATH} | grep "${HOME}/.local/bin")  ]]; then
    export PATH="${HOME}/.local/bin:${PATH}"
    export PATH="${XCI_PATH}/${POD_NAME}/bin:$PATH"
fi
