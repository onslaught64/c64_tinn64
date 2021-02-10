#!/bin/bash
WORKINGDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROJECT_ROOT="$(dirname "$WORKINGDIR")"
CONDA_ROOT="${PROJECT_ROOT}/miniconda"
[ -d "${CONDA_ROOT}" ] && exit 0
cd /tmp
wget -c https://repo.anaconda.com/miniconda/Miniconda3-py37_4.8.2-Linux-x86_64.sh
chmod u+x /tmp/Miniconda3-py37_4.8.2-Linux-x86_64.sh
/tmp/Miniconda3-py37_4.8.2-Linux-x86_64.sh -b -u -p $PROJECT_ROOT/miniconda
rm /tmp/Miniconda3-py37_4.8.2-Linux-x86_64.sh
