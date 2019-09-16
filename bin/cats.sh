#!/bin/bash
echo
echo "---------------------------------"
echo "Project Builder"
echo "---------------------------------"
ENVS=$(conda env list | awk '{print $1}' )
if [[ $ENVS = *"$1"* ]]; then
    source activate $1
else
   echo "Try again with the correct virtual environment"
   conda env list
   exit
fi;
cd data
python convert_just_cats.py
cd ..
cd pyTinn
python export_exp.py
python train.py training_cats.data
