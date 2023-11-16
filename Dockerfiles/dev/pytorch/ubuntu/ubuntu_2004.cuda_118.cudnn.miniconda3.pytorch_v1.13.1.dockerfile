FROM dev_nvidia_cuda_118_cudnn_miniconda3:20.04
LABEL maintainer="Arijit Bhowmick <arijit_bhowmick@outlook.com>"

# Fix timezone issues
ENV TZ=Asia/Kolkata
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
ENV DEBIAN_FRONTEND noninteractive # export DEBIAN_FRONTEND="noninteractive"
# ENV CONDA_DIR_PATH=/root/miniconda

RUN mkdir -p /data /scripts patches/ /installer
COPY scripts/ /scripts/
COPY patches/ /patches/
COPY scripts/startup.sh /


WORKDIR /workspace/

# Set environment variables for CUDA
ENV PATH=/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64:${LD_LIBRARY_PATH}
RUN echo "/usr/local/cuda/lib64" | sudo tee -a /etc/ld.so.conf && ldconfig

# Install pytorch [torch(v1.13.1)+torchvision(v0.14.1)]

## Install torch_v1.13.1
RUN /scripts/pytorch/torch/v1.13.1/conda/build_and_install.sh

## Install torchvision_v0.14.1
RUN /scripts/pytorch/torchvision/v0.14.1/conda/build_and_install.sh

## COMMONS ##

# Cleanup
## Removed initially supplied /data /scripts /installer directories
RUN rm -r /data /scripts /installer /patches
## APT cache cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

ENTRYPOINT /bin/bash /startup.sh
