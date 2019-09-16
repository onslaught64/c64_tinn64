#!/bin/bash
echo
echo "---------------------------------"
echo "Project Builder"
echo "---------------------------------"
source activate py35
cd pyTinn
python export_exp.py
python train.py mnist.data
