#!/bin/bash

# set -e

# CONDA_HOME_DIR=$HOME/miniconda3
CONDA_HOME_DIR=/usr/local/miniconda3
source ~/.bashrc

## Install Pytorch v0.14.1 ##
cd /tmp

pip install typing_extensions pytest 
sudo apt install -y cmake

conda install -y astunparse numpy ninja pyyaml mkl mkl-include setuptools cmake cffi typing_extensions future six requests dataclasses
conda install -y -c pytorch magma-cuda118

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
conda install -y cmake ninja numpy
pip install -r requirements.txt

conda install -y mkl mkl-include
# CUDA only: Add LAPACK support for the GPU if needed
conda install -y pyyaml
# (optional) If using torch.compile with inductor/triton, install the matching version of triton
# Run from the pytorch directory after cloning
# make triton



### Install pytorch
export CMAKE_PREFIX_PATH=${CONDA_PREFIX:-"$(dirname $(which conda))/../"}
python setup.py install


##### Test Pytorch Installation #####
cd /tmp && python3 -c "import torch; print(torch.rand(2, 3, device='cuda') @ torch.rand(3, 2, device='cuda'))"

### Output Some how looks similar like
# tensor([[0.5026, 0.1853],
#         [0.8356, 0.4575]], device='cuda:0')

## Cleanup
rm -r /tmp/pytorch