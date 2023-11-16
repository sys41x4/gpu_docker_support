FROM ubuntu:20.04

LABEL maintainer="Arijit Bhowmick <arijit_bhowmick@outlook.com>"

# Fix timezone issues
ENV TZ=Asia/Kolkata
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
ENV DEBIAN_FRONTEND noninteractive # export DEBIAN_FRONTEND="noninteractive"
# ENV CONDA_DIR_PATH=/root/miniconda

# COPY support/ /data/
RUN mkdir -p /data /scripts /installer
COPY scripts/ /scripts/
COPY scripts/startup.sh /

# Install necessary dependencies and update package lists
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    build-essential \
    curl \
    git \
    python3 \
    python3-pip \
    python3-dev \
    wget \
    libfreeimage-dev \
    ffmpeg
#    rustc \


WORKDIR /workspace/

RUN cd /tmp && \
    wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin -O /etc/apt/preferences.d/cuda-repository-pin-600 && \
    wget https://developer.download.nvidia.com/compute/cuda/11.8.0/local_installers/cuda-repo-ubuntu2004-11-8-local_11.8.0-520.61.05-1_amd64.deb -O /tmp/cuda-repo-ubuntu2004-11-8-local_11.8.0-520.61.05-1_amd64.deb && \
    dpkg -i /tmp/cuda-repo-ubuntu2004-11-8-local_11.8.0-520.61.05-1_amd64.deb && \
    cp /var/cuda-repo-ubuntu2004-11-8-local/cuda-*-keyring.gpg /usr/share/keyrings/ && \
    apt-get update && \
    apt-get -y install cuda && \
    # Remove the installer pkg
    rm -r /tmp/cuda-repo-ubuntu2004-11-8-local_11.8.0-520.61.05-1_amd64.deb
    
# Set environment variables for CUDA
ENV PATH=/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64:${LD_LIBRARY_PATH}
RUN echo "/usr/local/cuda/lib64" | sudo tee -a /etc/ld.so.conf && ldconfig


# Install CUDA-11.8
# RUN bash /scripts/setup/cuda-11.8/setup.sh

# Install CUDNN
# Somehow running the same CUDNN cinstaller script is not working
RUN /scripts/nvidia/cuda_118/cudnn_8_8_0_121/ubuntu_2004/setup-11.8-8.8.0.121.sh

## Running the CUDNN check script from Dockerfile will exit the docker buil compiler
# RUN /scripts/nvidia/cuda_118/cudnn_8_8_0_121/checks-11.8-8.8.0.121.sh


## COMMONS ##

# Cleanup
## APT cache cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/*
## Removed initially supplied /data /scripts /installer directories
RUN rm -r /data /scripts /installer


ENTRYPOINT /bin/bash /startup.sh
