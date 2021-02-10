#!/bin/bash
PROJECT="pytinn"
WORKINGDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROJECT_ROOT="$(dirname "$WORKINGDIR")"
export CONDA_ROOT="${PROJECT_ROOT}/miniconda"
__conda_setup="$(conda 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "${CONDA_ROOT}/etc/profile.d/conda.sh" ]; then
        . "${CONDA_ROOT}/etc/profile.d/conda.sh"
    else
        export PATH="${CONDA_ROOT}/bin:$PATH"
    fi
    eval "$__conda_setup"
fi
unset __conda_setup
ENVS=$(conda env list | awk '{print $PROJECT}' )
if [[ $ENVS = *"$PROJECT"* ]]; then
    conda activate ${PROJECT}
else
    exit 1
fi;
export PYTHONPATH=$PYTHONPATH:data:pyTinn/src
python $@
