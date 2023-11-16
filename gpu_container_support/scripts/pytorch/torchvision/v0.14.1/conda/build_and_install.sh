#!/bin/bash

set -e

# BUILD and Install torchvision-v0.14.1

PATCHES_DIR=/patches
CONDA_HOME_DIR=/usr/local/miniconda3
WORK_DIR=/tmp

source ~/.bashrc

export PATH=$CONDA_HOME_DIR:$PATH

### Install Pillow-SIMD  & libjpeg-turbo ###
cd $WORK_DIR

sudo apt-get update

wget https://github.com/libjpeg-turbo/libjpeg-turbo/archive/refs/tags/2.1.5.1.tar.gz
tar -xzf 2.1.5.1.tar.gz
cd libjpeg-turbo-2.1.5.1/

sudo apt install -y yasm

### Cleanup libjpeg-turbo ###
rm $WORK_DIR/2.1.5.1.tar.gz


##### https://gist.github.com/soumith/01da3874bf014d8a8c53406c2b95d56b
sudo apt install -y nasm zlib1g-dev

if ! $CONDA_HOME_DIR/bin/conda uninstall --force pillow -y; then
    # If an error occurs during uninstallation, handle it here
    echo "An error occurred while uninstalling 'pillow'. Proceeding..."
    :
fi

$CONDA_HOME_DIR/bin/conda install -y pillow 

# install libjpeg-turbo to $WORK_DIR/turbojpeg
git clone https://github.com/libjpeg-turbo/libjpeg-turbo
pushd libjpeg-turbo
    mkdir build
    cd build
    cmake .. -DCMAKE_INSTALL_PREFIX:PATH=/usr/local/turbojpeg
    make
    make install
popd

# install pillow-simd with jpeg-turbo support
git clone https://github.com/uploadcare/pillow-simd
pushd pillow-simd
CPATH=/usr/local/turbojpeg/include LIBRARY_PATH=/usr/local/turbojpeg/lib CC="cc -mavx2" $CONDA_HOME_DIR/bin/python setup.py install

# add turbojpeg to LD_LIBRARY_PATH
export LD_LIBRARY_PATH="/usr/local/turbojpeg/lib:$LD_LIBRARY_PATH"

### PATCH PYTORCH v1.13.1 ###
## pytorch patch for 11.8 | 8.9+PTX ###
cp $PATCHES_DIR/pytorch/torch/v1.13.1/conda/miniconda3/lib/python3.11/site-packages/torch/utils/cpp_extension.py $CONDA_HOME_DIR/lib/python3.11/site-packages/torch/utils/cpp_extension.py

##### Install Torch Vision #####
cd $WORK_DIR

sudo apt-get update
sudo apt-get install -y python3-pip
# pip3 install pillow

git clone https://github.com/pytorch/vision.git
cd vision
git checkout v0.14.1

$CONDA_HOME_DIR/bin/conda install -y -c conda-forge libpng jpeg ffmpeg
$CONDA_HOME_DIR/bin/pip install pillow pillow-simd

# Make sure your libjpeg-turbo and Pillow-SIMD are installed.
$CONDA_HOME_DIR/bin/python3 -c "from setup import get_dist; print(get_dist('pillow'))"

$CONDA_HOME_DIR/bin/python setup.py install

$CONDA_HOME_DIR/bin/pip install av


# Test Cases should be run in this place or the $WORK_DIR/vision directory will be removed after this

## Cleanup
rm -r $WORK_DIR/libjpeg-turbo-* $WORK_DIR/vision