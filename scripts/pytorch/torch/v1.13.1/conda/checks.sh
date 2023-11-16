#!/bin/bash

set -e

# CONDA_HOME_DIR=$HOME/miniconda3
CONDA_HOME_DIR=/usr/local/miniconda3
source ~/.bashrc

export PATH=$CONDA_HOME_DIR:$PATH

##### Test Pytorch Installation #####
cd /tmp && $CONDA_HOME_DIR/bin/python3 -c "import torch; print(torch.rand(2, 3, device='cuda') @ torch.rand(3, 2, device='cuda'))"

### Output Some how looks similar like
# tensor([[0.5026, 0.1853],
#         [0.8356, 0.4575]], device='cuda:0')