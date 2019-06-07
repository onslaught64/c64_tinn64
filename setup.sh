#!/bin/bash
echo
echo "---------------------------------"
echo "Anaconda Project Setup"
echo "---------------------------------"
echo ""
echo "(C)2017-2019 Thinking.Studio "
echo ""
echo ""

if [[ $1 = *"--help"* ]]; then
    echo "Usage:"
    echo "Invoke setup with the desired Anaconda environment name"
    echo ""
    echo "EXAMPLE:"
    echo "setup.sh py35"
    echo ""
    echo "This will either create a new environment called py35 OR use the existing environment called py35 (if it exists)"
    echo ""
    echo "If you don't set the environment name you will get a list of available environments. "
    echo ""
    echo ""
    exit
fi;

if [[ -z "$1" ]]; then
    echo "Use --help for usage info"
    echo ""
    echo "Please provide a valid virtual environment when calling Setup."
    conda env list
    echo ""
    echo ""
    exit
fi;

ENVS=$(conda env list | awk '{print $1}' )
if [[ $ENVS = *"$1"* ]]; then
    source activate $1
else
    read -p "Are you sure you want to create a new environment called $1 ? " -n 1 -r
    echo    # (optional) move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
       conda create -n "$1" python="3.5"
    else
       echo "Try again with the correct virtual environment"
       conda env list
       exit
    fi;
fi;

echo "Update Anaconda"
conda update -y -n base -c defaults conda

echo "Install PIP Packages"
pip install --upgrade pip
pip install cython
pip install pandas
pip install numpy
pip install progress

echo "Set PYTHONPATH"
export PYTHONPATH=$PYTHONPATH:data:pyTinn

echo "Creating output directory..."
mkdir output

