#!/bin/bash

set -e

# BUILD and Install torchvision-v0.14.1
CONDA_HOME_DIR=/usr/local/miniconda3
WORK_DIR=/tmp

source ~/.bashrc

# Testing TorchVision
cd test/ && \
$CONDA_HOME_DIR/bin/python3 test_datasets.py