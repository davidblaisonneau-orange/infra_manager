#!/bin/bash

export XCI_PATH=${XCI_PATH:-/opt/xci}
export XCI_FLAVOR=${XCI_FLAVOR:-mini}

export XCI_ANSIBLE_PIP_VERSION=${XCI_ANSIBLE_PIP_VERSION:-2.3.2.0}
export XCI_ANSIBLE_VERBOSE=${XCI_ANSIBLE_VERBOSE:--vvv}

export OS_FAMILY=${OS_FAMILY:-debian} # Only version supported for now
