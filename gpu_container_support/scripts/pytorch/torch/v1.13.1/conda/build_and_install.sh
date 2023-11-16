#!/bin/bash

set -e

# CONDA_HOME_DIR=$HOME/miniconda3
CONDA_HOME_DIR=/usr/local/miniconda3
source ~/.bashrc

export PATH=$CONDA_HOME_DIR:$PATH

## Install Pytorch v0.14.1 ##
cd /tmp

sudo apt-get update

$CONDA_HOME_DIR/bin/pip install typing_extensions pytest
sudo apt install -y cmake

$CONDA_HOME_DIR/bin/conda install -y astunparse numpy ninja pyyaml mkl mkl-include setuptools cmake cffi typing_extensions future six requests dataclasses
$CONDA_HOME_DIR/bin/conda install -y -c pytorch magma-cuda118

# Get the PyTorch Source

git clone --recursive https://github.com/pytorch/pytorch
cd pytorch

git checkout v1.13.1 # Or any version you want

# if you are updating an existing checkout
git submodule sync
git submodule update --init --recursive --jobs 0

sudo apt install -y openmpi-bin

## Install pytorch Dependencies

### Common
$CONDA_HOME_DIR/bin/conda install -y cmake ninja numpy
$CONDA_HOME_DIR/bin/pip install -r requirements.txt

$CONDA_HOME_DIR/bin/conda install -y mkl mkl-include
# CUDA only: Add LAPACK support for the GPU if needed
$CONDA_HOME_DIR/bin/conda install -y pyyaml
# (optional) If using torch.compile with inductor/triton, install the matching version of triton
# Run from the pytorch directory after cloning
# make triton



### Install pytorch
export CMAKE_PREFIX_PATH=${CONDA_PREFIX:-"$(dirname $(which conda))/../"}
$CONDA_HOME_DIR/bin/python setup.py install




## Cleanup
rm -r /tmp/pytorch