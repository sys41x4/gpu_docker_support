#!/bin/bash

CONDA_HOME_DIR=/usr/local/miniconda3
## Install cudnn pkgs

sudo apt-get update

## Install miniconda ##
mkdir -p $CONDA_HOME_DIR && \
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O $CONDA_HOME_DIR/miniconda.sh && \
/bin/bash $CONDA_HOME_DIR/miniconda.sh -b -u -p $CONDA_HOME_DIR

## Add Conda to path
echo "export PATH=$CONDA_HOME_DIR/bin:\$PATH" >> ~/.bashrc && \
source ~/.bashrc

## miniconda cleanup ##
rm -rf $CONDA_HOME_DIR/miniconda.sh