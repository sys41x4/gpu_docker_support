#!/bin/bash

# export PATH=/usr/local/cuda/bin:${PATH}
# export LD_LIBRARY_PATH=/usr/local/cuda/lib64:${LD_LIBRARY_PATH}

cd /tmp

wget https://github.com/arijit-bhowmick/gpu_docker_support/releases/download/v0.1.0/ubuntu2004_cuda118_cudnn_8.8.0.121.zip -O /tmp/cudnn_8.8.0.121.zip && \
unzip cudnn_8.8.0.121.zip && \
cd /tmp/cudnn_8_8_0_121/ubuntu/2004/amd64/cudnn-local-repo-8.8.0.121/ && \
dpkg -i ./*.deb && \
# Once the pkgs are installed the installer pkgs should be removed to reduce image size
cd /tmp && \
rm -r cudnn_8.8.0.121.zip cudnn_8_8_0_121

# Check cudnn version insstalled
cat /usr/include/x86_64-linux-gnu/cudnn_version_v8.h | grep CUDNN_MAJOR -A 2
