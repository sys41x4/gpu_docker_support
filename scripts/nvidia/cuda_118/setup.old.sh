#!/bin/bash

INSTALLER_DIR=/data/installers
PATCHES_DIR=/data/patches
CUDNN_INSTALLER_FILEPATH=$INSTALLER_DIR/11.8/20.04/amd64/cudnn.deb
CUDNN_INSTALLER_TEMP_DIR=$HOME/cudnn_install

# CONDA_HOME_DIR=$HOME/miniconda3
CONDA_HOME_DIR=/usr/local/miniconda3
## Install cudnn pkgs

sudo apt-get update


# Initial fix for cuda 11.8
export PATH="/usr/local/cuda/bin:$PATH"
export LD_LIBRARY_PATH="/usr/local/cuda/lib64:$LD_LIBRARY_PATH"

source ~/.bashrc

echo "/usr/local/cuda/lib64" | sudo tee -a /etc/ld.so.conf
sudo ldconfig

## Check cuda version
ldconfig -p | grep cuda
cat /usr/local/cuda/version.json | grep version -B 2


## Verify Cuda Installation using Test Cases
cd $HOME
git clone https://github.com/NVIDIA/cuda-samples.git
cd cuda-samples/
git checkout v11.8
# sudo apt install -y libfreeimage-dev
make -j$(nproc) > compile.log 2>&1 & # Make the test binary
# tail -f compile.log 
# Then let’s run some samples:
cd Samples/4_CUDA_Libraries/matrixMulCUBLAS
./matrixMulCUBLAS

cd ~/cuda-samples/Samples/5_Domain_Specific/p2pBandwidthLatencyTest
./p2pBandwidthLatencyTest


nvidia-smi nvlink -s

rm -rf ~/cuda_11.8.0_520.61.05_linux.run ~/cuda-samples

if [ -e "$CUDNN_INSTALLER_FILEPATH" ]; then
    # check if CUDNN_INSTALLER_FILEPATH is available, if available run the commands
    mkdir -p $CUDNN_INSTALLER_TEMP_DIR && \
    cp $CUDNN_INSTALLER_FILEPATH $CUDNN_INSTALLER_TEMP_DIR && \
    cd $CUDNN_INSTALLER_TEMP_DIR && \
    ar -x $CUDNN_INSTALLER_FILEPATH && \
    tar -xvf data.tar.xz && \
    cd var/cudnn-local-repo-ubuntu2004-8.8.0.121/ && \
    dpkg -i ./*.deb

    cat /usr/include/x86_64-linux-gnu/cudnn_version_v8.h | grep CUDNN_MAJOR -A 2

    ## CUDNN Checks

    cd /usr/src/cudnn_samples_v8/mnistCUDNN && \
    sudo make -j$(nproc) && \
    ./mnistCUDNN

    ## CUDNN Cleanups

    cd ~
    # rm -r $CUDNN_INSTALLER_TEMP_DIR
else
    echo "CUDNN Installer Not Available : $CUDNN_INSTALLER_FILEPATH"
    exit 1
fi

## Install miniconda ##
mkdir -p $CONDA_HOME_DIR
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O $CONDA_HOME_DIR/miniconda.sh
bash $CONDA_HOME_DIR/miniconda.sh -b -u -p $CONDA_HOME_DIR

## Add Conda to path
echo "export PATH=$CONDA_HOME_DIR/bin:\$PATH" >> ~/.bashrc
source ~/.bashrc

## miniconda cleanup ##
rm -rf $CONDA_HOME_DIR/miniconda.sh



## Install Pytorch ##
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



## pytorch patch for 11.8 | 8.9+PTX ###
cp $PATCHES_DIR/11.8/20.04/amd64/miniconda3/lib/python3.11/site-packages/torch/utils/cpp_extension.py $CONDA_HOME_DIR/lib/python3.11/site-packages/torch/utils/cpp_extension.py

##### Test Pytorch Installation #####
cd && python3 -c "import torch; print(torch.rand(2, 3, device='cuda') @ torch.rand(3, 2, device='cuda'))"

### Output Some how looks similar like
# tensor([[0.5026, 0.1853],
#         [0.8356, 0.4575]], device='cuda:0')


### Install Pillow-SIMD  & libjpeg-turbo ###
cd
wget https://github.com/libjpeg-turbo/libjpeg-turbo/archive/refs/tags/2.1.5.1.tar.gz
tar -xzf 2.1.5.1.tar.gz
cd libjpeg-turbo-2.1.5.1/

sudo apt install -y yasm

### Cleanup libjpeg-turbo ###
rm ~/2.1.5.1.tar.gz


##### https://gist.github.com/soumith/01da3874bf014d8a8c53406c2b95d56b
sudo apt install -y nasm zlib1g-dev

conda uninstall --force pillow -y

# install libjpeg-turbo to $HOME/turbojpeg
git clone https://github.com/libjpeg-turbo/libjpeg-turbo
pushd libjpeg-turbo
    mkdir build
    cd build
    cmake .. -DCMAKE_INSTALL_PREFIX:PATH=$HOME/turbojpeg
    make
    make install
popd

# install pillow-simd with jpeg-turbo support
git clone https://github.com/uploadcare/pillow-simd
pushd pillow-simd
CPATH=$HOME/turbojpeg/include LIBRARY_PATH=$HOME/turbojpeg/lib CC="cc -mavx2" python setup.py install

# add turbojpeg to LD_LIBRARY_PATH
export LD_LIBRARY_PATH="$HOME/turbojpeg/lib:$LD_LIBRARY_PATH"




##### Install Torch Vision #####
cd

sudo apt-get update
sudo apt-get install python3-pip
# pip3 install pillow

git clone https://github.com/pytorch/vision.git
cd vision
git checkout v0.14.1

conda install -y -c conda-forge libpng jpeg ffmpeg
pip install pillow-simd

# Make sure your libjpeg-turbo and Pillow-SIMD are installed.
python3 -c "from setup import get_dist; print(get_dist('pillow'))"

python setup.py install

# Testing TorchVision
pip install av
cd test/ && \
python3 test_datasets.py

# Install whisper module
pip install -U openai-whisper
cd
##### Cleanups #####
# rm -r $INSTALLER_DIR