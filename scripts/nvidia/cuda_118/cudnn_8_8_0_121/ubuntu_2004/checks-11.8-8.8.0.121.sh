#!/bin/bash

set -e

cd /tmp

## CUDNN sample Checks
# This CUDNN checks might exit docker build console, if the script is runned through Dockerfile entry
cd /usr/src/cudnn_samples_v8/mnistCUDNN && \
sudo make -j$(nproc) && \
./mnistCUDNN
