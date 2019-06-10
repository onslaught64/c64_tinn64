#!/bin/bash
echo
echo "---------------------------------"
echo "Project Builder"
echo "---------------------------------"
echo ""
echo ""
echo ""
echo ""

if [[ $1 = *"--help"* ]]; then
    echo "Usage:"
    echo "Invoke build with the desired pipeline name"
    echo ""
    echo "EXAMPLE:"
    echo "build.sh cats"
    echo ""
    exit
fi;

if [[ -z "$1" ]]; then
    echo "Use --help for usage info"
    echo ""
    echo "Pipelines:"
    echo ""
    echo "run"
    echo "build/runs the final demo, does not build data"
    echo ""
    echo "math"
    echo "build/runs the math unit test harness"
    echo ""
    echo "nn"
    echo "build/runs the neural net unit test harness"
    echo ""
    echo "qd"
    echo "transforms and trains the Quick! Draw! data and sets up the output dir for build. (requires you download it first!)"
    echo ""
    echo "cats"
    echo "transforms and trains the Quick! Draw! data and sets up the output dir for build - cats sample only. (requires you download it first!)"
    echo ""
    echo "mnist"
    echo "trains the MNIST handwriting data. (requires you download it using the url provided in the Tinn project first!)"
    echo ""
    exit
fi;

if [[ $1 = *"run"* ]]; then
    cd tinn-fe
    kick fe.s
    rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi
    x64 fe.prg >/dev/null
    exit
fi;

if [[ $1 = *"math"* ]]; then
    cd tinn-fe
    kick test-math.s
    rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi
    x64 test-math.prg >/dev/null
    exit
fi;

if [[ $1 = *"nn"* ]]; then
    cd tinn-fe
    kick test-nn.s
    rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi
    x64 test-nn.prg >/dev/null
    exit
fi;

if [[ $1 = *"build"* ]]; then
    cd tinn-fe
    kick fe.s
    exit
fi;

if [[ $1 = *"cats"* ]]; then
    source activate py35
    cd data
    python convert_just_cats.py
    cd ..
    cd pyTinn
    python export_exp.py
    python train.py training_cats.data
    exit
fi;

if [[ $1 = *"qd"* ]]; then
    source activate py35
    cd data
    python convert.py
    cd ..
    cd pyTinn
    python export_exp.py
    python train.py training.data
    exit
fi;

if [[ $1 = *"mnist"* ]]; then
    source activate py35
    cd pyTinn
    python export_exp.py
    python train.py mnist.data
    exit
fi;
