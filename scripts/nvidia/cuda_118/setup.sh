#!/bin/bash

sudo apt-get update

# Initial fix for cuda 11.8
export PATH="/usr/local/cuda/bin:$PATH"
export LD_LIBRARY_PATH="/usr/local/cuda/lib64:$LD_LIBRARY_PATH"

#source ~/.bashrc

echo "/usr/local/cuda/lib64" | sudo tee -a /etc/ld.so.conf
sudo ldconfig

## Check cuda version
ldconfig -p | grep cuda
cat /usr/local/cuda/version.json | grep version -B 2


## Verify Cuda Installation using Test Cases
cd /tmp
git clone https://github.com/NVIDIA/cuda-samples.git && \
cd cuda-samples/ && \
git checkout v11.8 && \
# sudo apt install -y libfreeimage-dev
make -j$(nproc) > compile.log 2>&1 & # Make the test binary
# tail -f compile.log 


# Then let’s run some samples:
cd Samples/4_CUDA_Libraries/matrixMulCUBLAS && \
./matrixMulCUBLAS

cd /tmp/cuda-samples/Samples/5_Domain_Specific/p2pBandwidthLatencyTest && \
./p2pBandwidthLatencyTest

nvidia-smi nvlink -s

cd /tmp
rm -rf /tmp/cuda_11.8.0_520.61.05_linux.run /tmp/cuda-samples

